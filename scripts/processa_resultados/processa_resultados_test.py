import pytest
from decimal import Decimal
from processa_resultados import *

master = '01-01-RAV1.pcap'
slave = '01-01-RAV2.pcap'


def test_is_master():
    assert is_master(master) == True
    assert is_master(slave) == False


def test_get_switch_port():
    assert get_switch_port(master) == "53464"


def test_get_last_packet_out():
    assert get_last_packet_out(
        master) == "  837  17.993292 192.168.2.11 → 192.168.2.10 OpenFlow 148 Type: OFPT_PACKET_OUT\n"


def test_get_first_role_request():
    assert get_first_role_request(
        slave, "53464") == "    1  20.699564 192.168.2.12 → 192.168.2.10 OpenFlow 90 Type: OFPT_ROLE_REQUEST\n"


def test_get_first_role_reply():
    assert get_first_role_reply(
        slave, "53464") == "    1  20.699761 192.168.2.10 → 192.168.2.12 OpenFlow 90 Type: OFPT_ROLE_REPLY\n"


def test_get_first_multipart_request():
    assert get_first_multipart_request(
        slave, "53464") == "    1  20.704851 192.168.2.12 → 192.168.2.10 OpenFlow 82 Type: OFPT_MULTIPART_REQUEST\n"


def test_get_first_multipart_reply():
    assert get_first_multipart_reply(
        slave, "53464") == "    1  20.705079 192.168.2.10 → 192.168.2.12 OpenFlow 370 Type: OFPT_MULTIPART_REPLY\n"


def test_get_first_packet_out():
    assert get_first_packet_out(
        slave, "53464") == "    1  20.787313 192.168.2.12 → 192.168.2.10 OpenFlow 193 Type: OFPT_PACKET_OUT\n"


def test_get_time():
    base_time = 17.993292
    first_time = "  837  17.993292 192.168.2.11 → 192.168.2.10 OpenFlow 148 Type: OFPT_PACKET_OUT\n"
    second_time = "    1  20.787313 192.168.2.12 → 192.168.2.10 OpenFlow 193 Type: OFPT_PACKET_OUT\n"
    assert get_time(base_time, first_time) == 0.0
    assert get_time(base_time, second_time) == 2.794021
