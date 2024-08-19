Feature: Test the codec

    Scenario: Transmit from the APB host to the VIP
        Scoreboard requires minimum 10 characters.
        * the host transmits character 0x0E
        * the host transmits character 0x1E
        * the host transmits character 0x2E
        * the host transmits character 0x3E
        * the host transmits character 0x4E
        * the host transmits character 0x5E
        * the host transmits character 0x6E
        * the host transmits character 0x7E
        * the host transmits character 0x8E
        * the host transmits character 0x9E
        * the host transmits character 0xAE

    Scenario: Transmit from the VIP to the APB host
        By default RXFIFO high water mark is set to 16.
        * the VIP transmits character 0x01
        * the VIP transmits character 0x11
        * the VIP transmits character 0x21
        * the VIP transmits character 0x31
        * the VIP transmits character 0x41
        * the VIP transmits character 0x51
        * the VIP transmits character 0x61
        * the VIP transmits character 0x71
        * the VIP transmits character 0x81
        * the VIP transmits character 0x91
        * the VIP transmits character 0xA1
        * the VIP transmits character 0xB1
        * the VIP transmits character 0xC1
        * the VIP transmits character 0xD1
        * the VIP transmits character 0xE1
        * the VIP transmits character 0xF1
