Start server
-----
ENVIRONMENT=development ruby harvester.rb
Start worker
-----
QUEUE=* VERBOSE=true ENVIRONMENT=development rake resque:work

modely App a Error asi udelat primo s pripojenim na mongodb a
neotravovat pres api crashdesk UI app. Problem je jak potom
sikovne synchronizovat tyto modely jak v crashdesk-harvestr
tak v crashdesk apps.

Start Firehose
-----
firehose server
