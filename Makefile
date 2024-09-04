-include .env

clean  :; forge clean


test-moxie :; forge test --fork-url ${RPC_URL}  -vvvv
