import os
import sys
import numpy as np

PACKET_IN = '(openflow_v5.type == 10)'
PACKET_OUT = '(openflow_v5.type == 13)'
ROLE_REQUEST = '(openflow_v5.type == 24)'
ROLE_REPLY = '(openflow_v5.type == 25)'
MULTIPART_REQUEST = '(openflow_v5.type == 18)'
MULTIPART_REPLY = '(openflow_v5.type == 19)'
FILE_NAME = "tmp"


def main():
    if len(sys.argv) < 2:
        print("Wrong number of args")
        return
    root = sys.argv[1]
    extract_results(root)


def get_time(base_time, line):
    if line == '':
        return 'x'
    return round(float(line.split()[0]) - base_time, 6)


def process_folder(folder, writable):
    onlyfiles = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    pcaps = list(filter(lambda k: 'pcap' in k, onlyfiles))
    os.chdir(folder)
    print(os.getcwd())
    master, slave = get_master_and_slave(pcaps)
    base_time = get_time(0, get_last_packet_out(master))
    switch_port = get_switch_port(slave)
    multipartcount = get_multi_part_count(slave, MULTIPART_REPLY, get_first_role_reply(slave, switch_port),
                             get_first_packet_out(slave, switch_port), switch_port)
    writable.write('{},'.format(folder[-2::]))
    writable.write('{},'.format(get_time(base_time, get_fist_fin_packet(master))))
    writable.write('{},'.format(get_time(base_time, get_first_syn_packet(slave, get_cap_ip(slave)))))
    writable.write('{},'.format(get_time(base_time, get_first_role_request(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_role_reply(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_multipart_request(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_multipart_reply(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_packet_out(slave, switch_port))))
    writable.write('{}\n'.format(multipartcount))
    os.chdir('..')


def get_cap_ip(pcap):
    return '192.168.2.11' if "RAV1" in pcap else '192.168.2.12'

def get_master_and_slave(pcaps):
    master = ''
    slave = ''
    for pcap in pcaps:
        if is_master(pcap):
            master = pcap
        else:
            slave = pcap
    return (master, slave)


def is_master(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}".format(pcap, ROLE_REQUEST, FILE_NAME)
    os.system(cmd)
    with open(FILE_NAME, "r") as file:
        total_lines = 0
        for lines in file:
            total_lines += 1
    os.remove(FILE_NAME)
    return False if total_lines > 0 else True


def get_last_packet_out(pcap):
    cmd = "tshark -2 -r {} -R '{}' -e frame.time_epoch -e tcp.srcport -e tcp.dstport -Tfields  > {}".format(
        pcap, PACKET_OUT, FILE_NAME)
    os.system(cmd)
    with open(FILE_NAME, "r") as file:
        last_packet = ''
        for lines in file:
            last_packet = lines
    os.remove(FILE_NAME)
    return last_packet


def get_first(packet_type, pcap, port):
    file_name = "tmp"
    cmd = "tshark -2 -r {} -R '{}' -e frame.time_epoch -e tcp.srcport -e tcp.dstport -Tfields > {}".format(pcap,
                                                                                                              packet_type,
                                                                                                              FILE_NAME)
    os.system(cmd)
    first_line = ''
    with open(file_name, "r") as file:
        for line in file:
            for split in (line.split()):
                if split == port:
                    first_line = line.split()[0]
                    os.remove(file_name)
                    return first_line


def get_first_role_request(pcap, port):
    return get_first(ROLE_REQUEST, pcap, port)


def get_first_role_reply(pcap, port):
    return get_first(ROLE_REPLY, pcap, port)


def get_first_multipart_request(pcap, port):
    return get_first(MULTIPART_REQUEST, pcap, port)


def get_first_multipart_reply(pcap, port):
    return get_first(MULTIPART_REPLY, pcap, port)


def get_first_packet_out(pcap, port):
    return get_first(PACKET_OUT, pcap, port)


def get_fist_fin_packet(pcap):
    cmd = "tshark -2 -r {} -R '(tcp.flags.fin == 1) && tcp.srcport == 6653' -e frame.time_epoch -e tcp.srcport -e tcp.dstport -Tfields   > {}".format(
        pcap, FILE_NAME)
    os.system(cmd)
    line = open(FILE_NAME, "r").readline()
    os.remove(FILE_NAME)
    return line


def get_first_syn_packet(pcap, ip):
    if ip[-1] == '2':
        ip = ip[:-1]+'1'
    else:
        ip = ip[:-1]+'2'
    cmd = "tshark -2 -r {} -R '(tcp.flags.syn == 1) && tcp.dstport == 6653 && (ip.dst=={})' -e frame.time_epoch -e tcp.srcport -e tcp.dstport -Tfields   > {}".format(
        pcap,ip, FILE_NAME)
    os.system(cmd)
    line = open(FILE_NAME, "r").readline()
    os.remove(FILE_NAME)
    return line


def get_switch_port(pcap):
    file_name = "{}_{}".format(pcap, "switch_port")
    cmd = "tshark -2 -r {} -R '{}' -e tcp.dstport -Tfields > {}".format(pcap, ROLE_REQUEST, file_name)
    os.system(cmd)
    first_switch_port = open(file_name, "r").readline().rstrip('\n')
    os.remove(file_name)
    return first_switch_port


def get_multi_part_count(pcap, packet_type, time_init, time_end, switch_port):
    cmd = "tshark -2 -r {} -R '{}' -e frame.time_epoch -e tcp.srcport -e tcp.dstport -Tfields  > {}" \
        .format(pcap, packet_type, FILE_NAME)
    os.system(cmd)
    count = 0
    with open(FILE_NAME, "r") as file:
        for line in file:
            if (float(line.split()[0]) > float(time_init)) and (float(line.split()[0]) < float(time_end)) and (switch_port ==line.split()[1]):
                count += 1
    os.remove(FILE_NAME)
    return count


'''Expects tests root folder'''


def extract_results(path_to_folder):
    os.chdir(path_to_folder)
    folder = os.getcwd().split("/")[-1]
    subfolders = [f.path for f in os.scandir('.') if f.is_dir()]
    with open("results-{}-test.csv".format(folder), 'w') as file:
        file.write('FOLDER,')
        file.write('FIN,')
        file.write('SYN,')
        file.write('ROLE REQUEST,')
        file.write('ROLE REPLY,')
        file.write('MULTIPART REQUEST,')
        file.write('MULTIPART REPLY,')
        file.write('PACKET OUT,')
        file.write('MULTIPART COUNT\n')

        for subfolder in subfolders:
            # file.write(subfolder+'\n')
            process_folder(subfolder, file)
    # (get_mean(file.name))


def get_mean(file):
    return np.loadtxt(file, delimiter=',').mean(axis=0)


if __name__ == "__main__":
    main()
