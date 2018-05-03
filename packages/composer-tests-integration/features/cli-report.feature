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

@cli @cli-report
Feature: CLI report steps

    Scenario: Using the CLI, I should get an error if I try and provide any command line arguments
    When I run the following CLI command, which should fail
        """
        composer report -idonotknowwhatiamdoing
        """
    Then The stderr information should include text matching /Unknown arguments/

    Scenario: Using the CLI, I can run a composer report command to create a file about the current environment
        When I run the following CLI command, which should pass
            """
            composer report
            """
        Then The stdout information should include text matching /Creating Composer report/
        And The stdout information should include text matching /Collecting diagnostic data.../
        And The stdout information should include text matching /Created archive file: composer-report-/
        And The stdout information should include text matching /Command succeeded/
        And The following 1 file should exist
            | composer-report-*.tgz | TARBALL |
