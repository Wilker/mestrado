import sys
import os
import subprocess

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

def process_folder(folder):
    onlyfiles = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    pcaps = list(filter(lambda k: 'pcap' in k, onlyfiles))

def is_master(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}_master_test".format(pcap, ROLE_REQUEST, pcap)
    os.system(cmd)
    with open("{}_master_test".format(pcap),"r") as file:
        total_lines = 0
        for lines in file:
            total_lines +=1
    os.remove("{}_master_test".format(pcap))
    return True if total_lines > 0 else False

def get_last_packet_out(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}_packets_out".format(pcap, PACKET_OUT, pcap)
    os.system(cmd)
    with open("{}_packets_out".format(pcap), "r") as file:
        last_packet = ''
        for lines in file:
            last_packet = lines
    os.remove("{}_packets_out".format(pcap))
    return last_packet

def get_first_role_request(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}_role_request".format(pcap, ROLE_REQUEST, pcap)
    os.system(cmd)
    line = open("{}_role_request".format(pcap), "r").readline()
    os.remove("{}_role_request".format(pcap))
    return line

def get_first_multipart_request(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}_multipart_request".format(pcap, MULTIPART_REQUEST, pcap)
    os.system(cmd)
    line = open("{}_multipart_request".format(pcap), "r").readline()
    os.remove("{}_multipart_request".format(pcap))
    return line

def get_first_multipart_reply(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}_multipart_reply".format(pcap, MULTIPART_REPLY, pcap)
    os.system(cmd)
    line = open("{}_multipart_reply".format(pcap), "r").readline()
    os.remove("{}_multipart_reply".format(pcap))
    return line

def get_first_packet_out(pcap):
    cmd = "tshark -2 -r {} -R '{}' > {}_packet_out".format(pcap, PACKET_OUT, pcap)
    os.system(cmd)
    line = open("{}_packet_out".format(pcap), "r").readline()
    os.remove("{}_packet_out".format(pcap))
    return line

if __name__ == "__main__":
    main()