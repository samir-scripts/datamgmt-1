<!DOCTYPE html>
<html>
<head>
    <title>Train Reservation System - Login</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; text-align: center; padding-top: 50px; }
        .container { background-color: #fff; width: 350px; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); margin: auto; }
        input[type="text"], input[type="password"] { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 3px; }
        input[type="submit"] { background-color: #28a745; color: white; border: none; padding: 10px 20px; cursor: pointer; border-radius: 3px; }
        input[type="submit"]:hover { background-color: #218838; }
        .error { color: red; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Login</h2>
        <%
            String error = request.getParameter("error");
            if (error != null) {
                out.println("<div class='error'>" + error + "</div>");
            }
        %>
        <form action="checkLoginDetails.jsp" method="POST">
            <input type="text" name="username" placeholder="Username" required/>
            <input type="password" name="password" placeholder="Password" required/>
            <input type="submit" value="Login"/>
        </form>
        <p>Don't have an account? <a href="register.jsp">Register here</a></p>
    </div>
</body>
</html>
