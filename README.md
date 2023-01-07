<b>Display DHCP Leases in Grafana</b>

This is a little thing I made to display the DHCP leases in my network using a table panel in Grafana.
At the moment it only works with the ISC DHCPD leases format.

It uses the SimpleJson Datasource which you can find here:
https://grafana.net/grafana/plugins/grafana-simple-json-datasource


<b>Usage</b>

- Install SimpleJson Datasource in Grafana.
- Install sinatra and thin gems
- Point the variable for the path in the script to your dhcpd.leases file and run the script.
- Point the SimpleJson Datasource to the server which runs the script
- Add a table panel which uses your Json Datasource

<b>Used technologies</b>
- Ruby
- Sinatra
- Thin
- json

If you have any ideas on what I could implement or what I can do better, please let me know!
