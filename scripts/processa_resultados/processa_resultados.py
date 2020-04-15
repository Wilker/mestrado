import os
import sys
import numpy as np

PACKET_IN = '(openflow_v5.type == 10)'
PACKET_OUT = '(openflow_v5.type == 13)'
ROLE_REQUEST = '(openflow_v5.type == 24)'
ROLE_REPLY = '(openflow_v5.type == 25)'
MULTIPART_REQUEST = '(openflow_v5.type == 18)'
MULTIPART_REPLY = '(openflow_v5.type == 19)'


def main():
    if len(sys.argv) < 2:
        print("Wrong number of args")
        return
    root = sys.argv[1]
    extract_results(root)


def get_time(base_time, line):
    return round(float(line.split()[0]) - base_time, 6)


def process_folder(folder, writable):
    onlyfiles = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    pcaps = list(filter(lambda k: 'pcap' in k, onlyfiles))
    os.chdir(folder)
    print(os.getcwd())
    master, slave = get_master_and_slave(pcaps)
    base_time = get_time(0, get_last_packet_out(master))
    switch_port = get_switch_port(slave)
    writable.write('{},'.format(get_time(base_time, get_fist_fin_packet(master))))
    writable.write('{},'.format(get_time(base_time, get_first_role_request(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_role_reply(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_multipart_request(slave, switch_port))))
    writable.write('{},'.format(get_time(base_time, get_first_multipart_reply(slave, switch_port))))
    writable.write('{}\n'.format(get_time(base_time, get_first_packet_out(slave, switch_port))))
    os.chdir('..')


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
    cmd = "tshark -2 -r {} -R '{}' > {}_master_test".format(pcap, ROLE_REQUEST, pcap)
    os.system(cmd)
    with open("{}_master_test".format(pcap), "r") as file:
        total_lines = 0
        for lines in file:
            total_lines += 1
    os.remove("{}_master_test".format(pcap))
    return False if total_lines > 0 else True


def get_last_packet_out(pcap):
    cmd = "tshark -2 -r {} -R '{}' -e frame.time_relative -e tcp.srcport -e tcp.dstport -Tfields  > {}_packets_out".format(
        pcap, PACKET_OUT, pcap)
    os.system(cmd)
    with open("{}_packets_out".format(pcap), "r") as file:
        last_packet = ''
        for lines in file:
            last_packet = lines
    os.remove("{}_packets_out".format(pcap))
    return last_packet


def get_first(packet_type, pcap, port):
    file_name = "tmp"
    cmd = "tshark -2 -r {} -R '{}' -e frame.time_relative -e tcp.srcport -e tcp.dstport -Tfields > {}".format(pcap,
                                                                                                              packet_type,
                                                                                                              file_name)
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
    cmd = "tshark -2 -r {} -R '(tcp.flags.fin == 1) && tcp.srcport == 6653' -e frame.time_relative -e tcp.srcport -e tcp.dstport -Tfields   > {}_packet_out".format(
        pcap, pcap)
    os.system(cmd)
    line = open("{}_packet_out".format(pcap), "r").readline()
    os.remove("{}_packet_out".format(pcap))
    return line


def get_first_syn_packe(pcap):
    cmd = "tshark -2 -r {} -R '(tcp.flags.syn == 1) && tcp.srcport == 6653' -e frame.time_relative -e tcp.srcport -e tcp.dstport -Tfields   > {}_packet_out".format(
        pcap, pcap)
    os.system(cmd)
    line = open("{}_packet_out".format(pcap), "r").readline()
    os.remove("{}_packet_out".format(pcap))
    return line


def get_switch_port(pcap):
    file_name = "{}_{}".format(pcap, "switch_port")
    cmd = "tshark -2 -r {} -R '{}' -e tcp.dstport -Tfields > {}".format(pcap, ROLE_REQUEST, file_name)
    os.system(cmd)
    first_switch_port = open(file_name, "r").readline().rstrip('\n')
    os.remove(file_name)
    return first_switch_port


'''Expects tests root folder'''


def extract_results(path_to_folder):
    os.chdir(path_to_folder)
    folder = os.getcwd().split("/")[-1]
    subfolders = [f.path for f in os.scandir('.') if f.is_dir()]
    with open("results-{}-test.csv".format(folder), 'w') as file:
        file.write('FIN - master')
        file.write('')
        file.write('')
        file.write('')
        file.write('')
        file.write('\n')
        for subfolder in subfolders:
            # file.write(subfolder+'\n')
            process_folder(subfolder, file)
    print(get_mean(file.name))


def get_mean(file):
    return np.loadtxt(file, delimiter=',').mean(axis=0)


if __name__ == "__main__":
    main()
