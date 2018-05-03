/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

const fs = require('fs');
const os = require('os');
const { sep } = require('path');
const util = require('util');

const Composer = require('./composer');

module.exports = function () {
    let tasks = {};
    let busnets = {};
    let aliasMap = new Map();

    this.Before(function (scenarioResult) {

        // Let's use a clean temporary directory for each scenario
        const mkdtemp = util.promisify(fs.mkdtemp);
        const tmpDir = os.tmpdir();

        return mkdtemp(`${tmpDir}${sep}`).then((scenarioDir) => {
            aliasMap.set('SCENARIO_DIR', scenarioDir);

            const uri = scenarioResult.scenario.uri;
            const errorExpected = scenarioResult.scenario.steps.some((step) => {
                return !!step.name.match(/^I should get an error/);
            });
            this.composer = new Composer(uri, errorExpected, tasks, busnets, aliasMap);
        });
    });

    this.After(function () {
        return Promise.resolve();
    });

};
