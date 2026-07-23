<!DOCTYPE html>
<html>
<head>
    <title>Register - Train Reservation</title>
    
</head>
<body>
    <div class="container">
        <h2>Customer Registration</h2>
        <%
            String error = request.getParameter("error");
            if (error != null) {
                out.println("<div class='error'>" + error + "</div>");
            }
        %>
        <form action="registerAction.jsp" method="POST">
            <input type="text" name="first_name" placeholder="First Name" required/>
            <input type="text" name="last_name" placeholder="Last Name" required/>
            <input type="email" name="email" placeholder="Email" required/>
            <input type="text" name="username" placeholder="Username" required/>
            <input type="password" name="password" placeholder="Password" required/>
            <input type="submit" value="Register"/>
        </form>
        <p>Already have an account? <a href="login.jsp">Login here</a></p>
    </div>
</body>
</html>
