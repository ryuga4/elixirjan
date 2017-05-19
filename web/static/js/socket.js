// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
var id = JSON.stringify(new Date());
let channel = socket.channel("room:lobby", {name: id})

var licznik =0





/*

var keys = {};

$(document).keydown(function (e) {
    keys[e.which] = true;

    for(var i in keys) checkKey(i)
});

$(document).keyup(function (e) {
    delete keys[e.which];
    //$('#helper').html("false")
    for(var i in keys) checkKey(i)
});


function checkKey(e) {

    e = e || window.event;

    if (e == '38') {
        channel.push("forward", {"name": "default"})
    }
    else if (e == '40') {
        // down arrow
    }
    else if (e == '37') {
        channel.push("turn_left", {"name": "default"})
    }
    else if (e == '39') {
        channel.push("turn_right", {"name": "default"})
    }

}
*/

var Key = {
    _pressed: {},

    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,

    isDown: function(keyCode) {
        return this._pressed[keyCode];
    },
    check: function() {
        if(this._pressed[Key.UP]&&!this._pressed[Key.DOWN]) channel.push("forward", {"name": id})
        if(this._pressed[Key.DOWN]&&!this._pressed[Key.UP]) channel.push("stop", {"name": id})
        if(this._pressed[Key.LEFT]&&!this._pressed[Key.RIGHT]) channel.push("turn_left", {"name": id})
        if(this._pressed[Key.RIGHT]&&!this._pressed[Key.LEFT]) channel.push("turn_right", {"name": id})
        if(this._pressed[Key.UP]&&this._pressed[Key.DOWN]) channel.push("move_up", {"name": id})
        if(this._pressed[Key.LEFT]&&this._pressed[Key.RIGHT]) channel.push("turning_up", {"name": id})
        if(!this._pressed[Key.UP]&&!this._pressed[Key.DOWN]) channel.push("move_up", {"name": id})
        if(!this._pressed[Key.LEFT]&&!this._pressed[Key.RIGHT]) channel.push("turning_up", {"name": id})
    },
    onKeydown: function(event) {
        if (this._pressed[event.keyCode]) return 0
        console.log(this._pressed)
        this._pressed[event.keyCode] = true;
        this.check()
    },

    onKeyup: function(event) {
        //console.log(this._pressed)
        if (!this._pressed[event.keyCode]) return 0
        this._pressed[event.keyCode] = false;
        this.check()
    }
};

window.addEventListener('keyup', function(event) { Key.onKeyup(event); }, false);
window.addEventListener('keydown', function(event) { Key.onKeydown(event); }, false);
function update() {
    //if (Key.isDown(Key.UP)) channel.push("forward", {"name": id});
   // if (Key.isDown(Key.LEFT)) channel.push("turn_left", {"name": id});
   // if (Key.isDown(Key.DOWN)) channel.push("stop", {"name": id});
    //if (Key.isDown(Key.RIGHT)) channel.push("turn_right", {"name": id});
};

setInterval(()=>{channel.push("update", {body: 0})},10)
setInterval(()=>{update()},1)

var helper = {
    inc: 0,
    n: 0
}



//setInterval(function(){ }, 1000);
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("update", payload => {
    helper.n+=1
    helper.inc+=payload.time.val
    console.log(payload.value[0].inc+" "+helper.inc/helper.n)

    //licznik+=1
    render()
    for (var i in payload.value) {
        //channel.push("alert",{msg: JSON.stringify(payload.value[i])})
        triangle(payload.value[i].position[0],payload.value[i].position[1],payload.value[i].angle,payload.value[i].name===id)
    }
})

var canvas = document.getElementById("myCanvas")
var ctx = canvas.getContext('2d')

function render() {
    ctx.fillStyle = 'rgb(255,255,255)';
    ctx.fillRect(0, 0, 1000, 700);

    ctx.lineWidth = 1;

}

function triangle(x,y,angle,player){
    if (!player) ctx.fillStyle= 'rgb(0,0,0)'
    else ctx.fillStyle= 'rgb(120,30,230)'
    var angle2=angle//Math.PI/2
    var path=new Path2D();
    path.moveTo(x+Math.cos(angle2)*100,y+Math.sin(angle2)*100);
    path.lineTo(x+Math.cos(angle2+2*Math.PI/3)*70,y+Math.sin(angle2+2*Math.PI/3)*70);
    path.lineTo(x+Math.cos(angle2-2*Math.PI/3)*70,y+Math.sin(angle2-2*Math.PI/3)*70);
    ctx.fill(path);
}




















export default socket
