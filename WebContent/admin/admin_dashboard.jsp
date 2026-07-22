<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
</head>
<body>
    <h1>Welcome, Admin <%= session.getAttribute("user") %>!</h1>
    <ul>
        <li><a href="manage_reps.jsp">Manage Customer Representatives</a></li>
        <li><a href="sales_report.jsp">Sales Reports</a></li>
        <li><a href="list_reservations.jsp">List Reservations</a></li>
        <li><a href="revenue_report.jsp">Revenue Reports</a></li>
        <li><a href="top_customers.jsp">Top Customers</a></li>
        <li><a href="active_lines.jsp">Most Active Transit Lines</a></li>
    </ul>
    <p><a href="../logout.jsp">Logout</a></p>
</body>
</html>
