#!/bin/bash

# shellcheck source=/dev/null

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && source <(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/utilities.sh")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    # 'At first you're like "shellcheck is awesome" but then you're
    #  like "wtf[,] [why] are we still using bash[?]"'.
    #
    #  (from: https://twitter.com/astarasikov/status/568825996532707330)

    find \
        ../install.sh \
		../test \
        -type f \
        -exec shellcheck \
        {} +

    print_result $? "Run code through ShellCheck"

}

main
