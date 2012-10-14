Crashdesk - Harvester
=====================

Quick run
---------
- bundle install --binstubs
- ./bin/foreman start

Slow run
--------

Start server
------------
RACK_ENV=development ruby harvester.rb

Start worker
------------
QUEUE=* VERBOSE=true RACK_ENV=development rake resque:work

modely App a Error asi udelat primo s pripojenim na mongodb a
neotravovat pres api crashdesk UI app. Problem je jak potom
sikovne synchronizovat tyto modely jak v crashdesk-harvestr
tak v crashdesk apps.

Start Firehose
--------------
firehose server
