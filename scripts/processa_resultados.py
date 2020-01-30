import sys
import os
import subprocess

PACKET_IN = '(openflow_v5.type == 10)'
PACKET_OUT = '(openflow_v5.type == 14)'
ROLE_REQUEST = '(openflow_v5.type == 24)'
ROLE_REPLY = '(openflow_v5.type == 25)'
MULTIPART_REQUEST = '(openflow_v5.type == 25)'
MULTIPART_REPLY = '(openflow_v5.type == 25)'

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


if __name__ == "__main__":
    main()