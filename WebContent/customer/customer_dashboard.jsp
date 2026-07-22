<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard</title>
</head>
<body>
    <h1>Welcome, <%= session.getAttribute("fullName") %>!</h1>
    <ul>
        <li><a href="search_schedules.jsp">Search Train Schedules</a></li>
        <li><a href="view_reservations.jsp">My Reservations</a></li>
        <li><a href="ask_question.jsp">Ask Customer Service a Question</a></li>
    </ul>
    <p><a href="../logout.jsp">Logout</a></p>
</body>
</html>
