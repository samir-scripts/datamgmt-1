<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer_rep".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Representative Dashboard</title>
</head>
<body>
    <h1>Welcome, Rep <%= session.getAttribute("user") %>!</h1>
    <ul>
        <li><a href="manage_schedules.jsp">Manage Train Schedules</a></li>
        <li><a href="customer_questions.jsp">Customer Questions</a></li>
        <li><a href="station_schedules.jsp">Station Schedules</a></li>
        <li><a href="line_reservations.jsp">Transit Line Reservations</a></li>
    </ul>
    <p><a href="../logout.jsp">Logout</a></p>
</body>
</html>
