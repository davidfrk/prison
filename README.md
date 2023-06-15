# Prisoner's Dilemma

This project allows you to run a competition for the Prisoner's Dilemma game, in which each bot participant will implement its own strategy as an independent agent.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Contributing](#contributing)
- [Testing](#testing)
- [License](#license)

## Installation

This project is based on Unix Shell. To have it ready, you only need to clone this repository.
Keep in mind that this repository doesn't require anything else, but your bots may. Make sure you have the proper requirements for all allowed bots.

## Usage

Bots go into the prisoners subfolder, and they are required to possess a 'run.sh' script that compiles and runs them. Feel free to write your bots in any language, but be sure the machine running the competition has their language requirements set up.

To run the competition, use the following command:
'''shell
$ ./run_prisoners_dilemma.sh 10
'''
The number of rounds is specified as a parameter.

To obtain the list of prisoners, use:
'''shell
$ ./list_prisoners.sh
'''

Additionally you can run each prisoner against itself using:
'''shell
$ ./run_each_prisoner.sh
'''

## Features

- Challenge description provided. Check it out.
- The score table can be found in prison.log file.

## Testing

- All calls can be found in calls.log
- All answers can be found in answers.log

## License

This project is licensed under the MIT License.