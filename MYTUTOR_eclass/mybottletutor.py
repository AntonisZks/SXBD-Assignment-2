from bottle import run, request, route


@route('/login')
def login():
    return '''
 <form action="/login" method="post">
 Username: <input name="username" type="text" />
 Password: <input name="password" type="password" />
 <input value="Login" type="submit" />
 </form>
 '''


@route('/login', method='POST')
def do_login():
    username = request.forms.get('username')
    password = request.forms.get('password')
    return "<p>your login information was correct! </p>"

# using HTML to make it look nicer
@route('/display_list')
def display_raw_html():
    my_list = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    # First we put the stuff at the top, adding "n" in there
    html = "<h1>The " + str(len(my_list)) + " list items are</h1>" + "\n" + "<ul>"
    
    # for each factor, we make a <li> item for it
    for f in my_list:
        html += "<li>" + str(f) + "</li>" + "\n"
    html += "</ul> </body>"  # the close tags at the bottom
    
    return html


run(host='localhost', port=8080, debug=True)
