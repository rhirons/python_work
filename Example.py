from __future__ import division
from __future__ import print_function
from __builtin__ import input
import math

#################
#Number Examples#
#################

#Example1
swallow_limit = 60 / 3
swallows_per_cherry = 8 / swallow_limit

print ('Swallow limit is:',(int(swallow_limit)))
print ('Swallows per cherry is:',(swallows_per_cherry))

#Example 2
perc = 1/3
coco_wt = 1450
macaw_wt = 900
macaw_limit = macaw_wt * perc
print ('Macaw Limit is:',macaw_limit)

#Example 3
num_macaws = coco_wt / macaw_limit
print ('Number of macaws:',int(math.ceil(num_macaws)))

#################
#String examples#
#################
print ('\n')

#Example 1
first_name = 'Monty'
last_name = 'Python'
full_name = first_name + ' ' + last_name
print(full_name)

#Example 2
name = 'Monty Python'
description = 'sketch comedy group'
year = 1969
# str() converts passed variable to string. 
sentance = name + ' is a ' + description + ' formed in ' + str(year)
print (sentance)

#Example 3
famous_sketch1 = "\n\tHell's Grannies"
famous_sketch2 = '\n\tThe Dead Parrot'
print ('Famous work:',famous_sketch1,famous_sketch2)

#Example 4
greeting = 'HELLO WORLD!'
#len prints the size of the string
print ('\n' + str(len(greeting)))

#Example 5 - Can print specific chars from a string with string_name[X] or a range string_name[1:3]
word1 = 'Good'
end1 = word1[1] + word1[3]
print ('\n' + end1)

#################
#Conditional Ex #
#################

#If statements
num_knights = 10
day = 'Wednesday'
if num_knights < 3:
    print('\nRetreat!')
elif num_knights == 10:
    print('\nTrojan Rabbit')
elif day == 'Tuesday':
    print('\nTaco Night!')
else:
    print('\nTruce?')

#AND and OR statements
if num_knights < 3 or day == 'Monday':
    print('\nRetreat!')
elif num_knights >= 10 and day == 'Wednesday':
    print('\nTrojam Rabbit!')
else:
    print('\nTruce?')

#User imput
day_user = raw_input('\nEnter day of the week: ')
print('You entered: ', day_user)

num_knights_user = int(raw_input('\nEnter number of knights: '))
print('You entered:',num_knights_user)

enemy = raw_input('\nInput type of enemy: ')
print('You entered:',enemy)

if enemy == 'Killer Bunny':
    print('\nHoly hand grenade!')
else:
    if num_knights_user < 3 or day_user == 'Monday':
        print('\nRetreat!')
    elif num_knights_user >= 10 and day_user == 'Wednesday':
        print('\nTrojan Rabbit!')
    else:
        print('\nTruce')


########################
#Flying Through Python##
########################








