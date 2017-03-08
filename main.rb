require 'sinatra'
require 'json'

$leasespath = "/var/lib/dhcp/dhcpd.leases"

set :environment, :production
set :bind, '0.0.0.0'
set :port, 8000

def parseleases(path)
  leases = []
  $inlease = false
  File.read(path).each_line do |line|
    case line
      when /^\s*lease(.*)\{/
        $ip = line[/^\s*lease\s(.*)\s\{/, 1]
        $inlease = true
      when /^\}/
        $inlease = false
        leases.push([$ip, $hostname, $mac,$hardwaretype, $bindingstate, $starttime, $endtime, $vendor])
        $ip = nil
        $vendor = nil
        $bindingstate = nil
        $starttime = nil
        $endtime = nil
        $hardwaretype = nil
        $mac = nil
        $hostname = nil
      when /^\s*set vendor-class-identifier(.*)/
        if $inlease
          $vendor = line[/^\s*set vendor-class-identifier\s=\s\"(.*)\";/, 1]
        end
      when /^\s*binding state (.*);$/
        if $inlease
          $bindingstate = line[/binding state (.*);/,1]
        end
      when /^\s*starts\s\d\s(.*);/
        if $inlease
          $starttime = line[/^\s*starts\s\d\s(.*);/,1];
        end
      when /^\s*ends\s\d\s(.*);/
        if $inlease
          $endtime = line[/^\s*ends\s\d\s(.*);/,1];
        end
      when /^\s*hardware\s(.*?)\s(.*);/
        if $inlease
          $hardwaretype = line[/^\s*hardware\s(.*?)\s(.*);/,1];
          $mac = line[/^\s*hardware\s(.*?)\s(.*);/,2];
        end
      when /^\s*client-hostname\s\"(.*)\";/
        if $inlease
          $hostname = line[/^\s*client-hostname\s\"(.*)\";/,1];
        end
    end
  end
  columns = [{:text => "IP", :type => "string"}, {:text => "Hostname", :type => "string"}, {:text => "MAC", :type => "string"},
            {:text => "Hardware Type", :type => "string"}, {:text => "State", :type => "string"}, {:text => "Start", :type => "string"},
            {:text => "End", :type => "string"}, {:text => "Vendor", :type => "string"}]
  [{:target => "dhcpleases", :columns => columns, :rows => leases, :type => "table"}]
end

get '/' do
  status 200
end

post '/search' do
  leases = parseleases($leasespath)
  $leases = leases
  result = []
  leases.each_index do |index|
    result.push(leases[index][:target])
  end
  JSON.pretty_generate(result)
end

post '/query' do
  req = JSON.parse(request.body.read.to_s)
  result = nil
  req["targets"].each do |target|
    if target["target"] == "dhcpleases"
      result = JSON.pretty_generate(parseleases($leasespath))
    end
  end
  result
end