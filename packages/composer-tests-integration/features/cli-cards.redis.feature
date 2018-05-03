#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

@cli @cli-cards-redis
Feature: CLI cards steps using redis

    Background:
        Given I have admin business cards available
        And I have setup a redis card wallet environment

    Scenario: Using the CLI, I can create a business network card using a connection profile and certificates
        Given I have the following files available
            | ../hlfv1/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem |
            | ../hlfv1/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/key.pem                          |
            | ../profiles/basic-connection-org1.json                                                                                               |
        When I run the following CLI command, which should pass
            | command | composer card create              |
            | -p      | ./basic-connection-org1.json      |
            | -u      | PeerAdmin                         |
            | -c      | ./Admin@org1.example.com-cert.pem |
            | -k      | ./key.pem                         |
            | -r      | PeerAdmin                         |
            | -r      | ChannelAdmin                      |
            | -f      | ./PeerAdmin.card                  |

        Then The stdout information should include text matching /Command succeeded/
        And The following 4 files should exist
            | Admin@org1.example.com-cert.pem |                 |
            | key.pem                         |                 |
            | basic-connection-org1.json      |                 |
            | PeerAdmin.card                  | PEER_ADMIN_CARD |

    Scenario: Using the CLI, I can import a business network card
        Given I run the following CLI command using the alias PEER_ADMIN_CARD, which should pass
            """
            composer card import --file PEER_ADMIN_CARD
            """
        Then The stdout information should include text matching /Successfully imported business network card/
        And The stdout information should include text matching /Card file: ./tmp/PeerAdmin.card/
        And The stdout information should include text matching /Card name: PeerAdmin@hlfv1/
        And The stdout information should include text matching /Command succeeded/

    Scenario: Using the CLI, I can see the card that I just imported in the list of cards
        Given I run the following CLI command, which should pass
            """
            composer card list
            """
        Then The stdout information should include text matching /The following Business Network Cards are available:/
        And The stdout information should include text matching /Connection Profile: hlfv1/
        And The stdout information should include text matching /┌─+┬─+┬─+┐/
        And The stdout information should include text matching /│ Card Name\s+│ UserId\s+│ Business Network\s+│/
        And The stdout information should include text matching /├─+┼─+┼─+┤/
        And The stdout information should include text matching /│ PeerAdmin@hlfv1\s+│ PeerAdmin\s+│\s+│/
        And The stdout information should include text matching /└─+┴─+┴─+┘/
        And The stdout information should include text matching /Command succeeded/

    Scenario: When using the CLI, I can see the details of the card that I just imported
        Given I run the following CLI command, which should pass
            """
            composer card list -c PeerAdmin@hlfv1
            """
        Then The stdout information should include text matching /userName:            PeerAdmin/
        And The stdout information should include text matching /description:/
        And The stdout information should include text matching /businessNetworkName:/
        And The stdout information should include text matching /identityId:          [0-9a-z]{64}/
        And The stdout information should include text matching /roles:/
        And The stdout information should include text matching /- ChannelAdmin/
        And The stdout information should include text matching /connectionProfile:/
        And The stdout information should include text matching /  name:   hlfv1/
        And The stdout information should include text matching /  x-type: hlfv1/
        And The stdout information should include text matching /credentials:         Credentials set/
        And The stdout information should include text matching /Command succeeded/

    Scenario: Using the CLI, I should get an error if I try to delete a card which doesn't exist
        Given I run the following CLI command, which should fail
            """
            composer card delete -c nobody@penguin
            """
        Then The stdout information should include text matching /Command failed/

    Scenario: Using the CLI, I can export a card that exists in my wallet
        Given I run the following CLI command, which should pass
            """
            composer card export --card PeerAdmin@hlfv1 --file ./ExportedPeerAdmin.card
            """
        Then The stdout information should include text matching /Command succeeded/
        And I have the following files
            | ExportedPeerAdmin.card |

    Scenario: Using the CLI, I can delete a named card that exists
        Given I run the following CLI command, which should pass
            """
            composer card delete --card PeerAdmin@hlfv1
            """
        Then The stdout information should include text matching /Command succeeded/

    Scenario: Using the CLI, I get a relevant message when I import a card that has invalid name format created from an invalid common connection profile.
        Given I have the following files available
            | ../resources/cards/PeerAdminInvalidName@hlfv1.card |
        When I run the following CLI command, which should fail
            """
            composer card import --file ./PeerAdminInvalidName@hlfv1.card
            """
        Then The stdout information should include text matching /Failed to import the business network card/
        And The stdout information should include text matching /keyword:    type/
        And The stdout information should include text matching /dataPath:   .name/
        And The stdout information should include text matching /schemaPath: #/properties/name/type/
        And The stdout information should include text matching /message:    should be string/
        And The stdout information should include text matching /Errors found in the connection profile in the card/
