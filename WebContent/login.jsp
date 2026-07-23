<!DOCTYPE html>
<html>
<head>
    <title>Train Reservation System - Login</title>
    
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
