<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
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
    <title>Top Customer</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="admin_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Best Customer (Highest Total Revenue)</h2>
        <%
            Connection con = null;
            Statement st = null;
            ResultSet rs = null;
            try {
                con = DatabaseConnection.getConnection();
                st = con.createStatement();
                String query = "SELECT c.first_name, c.last_name, SUM(r.total_fare) as revenue " +
                               "FROM RESERVATION r " +
                               "JOIN CUSTOMER c ON r.cid = c.cid " +
                               "GROUP BY c.cid " +
                               "ORDER BY revenue DESC LIMIT 1";
                rs = st.executeQuery(query);
                if(rs.next()) {
                    out.println("<p>The customer who generated the most revenue is:</p>");
                    out.println("<div class='highlight'>" + rs.getString("first_name") + " " + rs.getString("last_name") + " ($" + rs.getString("revenue") + ")</div>");
                } else {
                    out.println("<p>No data available.</p>");
                }
            } catch(Exception e) { e.printStackTrace(); } finally {
                if (rs != null) rs.close();
                if (st != null) st.close();
                if (con != null) con.close();
            }
        %>
    </div>
</body>
</html>
