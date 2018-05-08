from time import sleep
from random import randint

def handler(event, context):
    #TODO: assume a role
    while True:
        duration = randint(20, 30)
        print('Sleeping for {} seconds'.format(duration))
        sleep(duration)
