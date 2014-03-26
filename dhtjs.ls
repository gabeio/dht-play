dht=require \dht.js
argv=require(\optimist).argv

if argv.debug
  console.log argv.port
  process.exit

# Create DHT node (server)
node = dht.node.create parseInt argv.port/* optional UDP port there */

# Connect to known node in network
node.connect(
  #id: new Buffer  #(/* 160bit node id */), #/* <-- optional */
  address: argv.conhost
  port: parseInt argv.conport
)

# Tell everyone that you have services to advertise
hash = new Buffer [0,5,4,3,2,1,6,7,8,9,0,1,3,5,8,9,6,7,8,9] #(/* 160 bit infohash */);
node.advertise hash, parseInt argv.conport # port

# Wait for someone to appear
node.on \peer:new, (infohash, peer, isAdvertised)->
  # Ignore other services
  if !isAdvertised
    return 0

  console.log peer.address, peer.port

  # Stop listening
  node.close()

  # Returns node's state as a javascript object
  state = node.save()

  # Create node from existing state
  old = dht.node.create state

  # Just cleaning up
  old.close()