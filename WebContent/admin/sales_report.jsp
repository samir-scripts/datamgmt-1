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
    <title>Sales Report</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="admin_dashboard.jsp">&larr; Dashboard</a>
        </div>
        <h2>Sales Report by Month</h2>
        
        <table>
            <tr><th>Month</th><th>Total Reservations</th><th>Total Revenue</th></tr>
            <%
                Connection con = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    st = con.createStatement();
                    String query = "SELECT DATE_FORMAT(reservation_date, '%Y-%m') as month, COUNT(reservation_number) as num_reservations, SUM(total_fare) as revenue " +
                                   "FROM RESERVATION " +
                                   "GROUP BY month " +
                                   "ORDER BY month DESC";
                    rs = st.executeQuery(query);
                    while(rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("month") + "</td>");
                        out.println("<td>" + rs.getInt("num_reservations") + "</td>");
                        out.println("<td>$" + (rs.getString("revenue") == null ? "0" : rs.getString("revenue")) + "</td>");
                        out.println("</tr>");
                    }
                } catch(Exception e) { e.printStackTrace(); } finally {
                    if (rs != null) rs.close();
                    if (st != null) st.close();
                    if (con != null) con.close();
                }
            %>
        </table>
    </div>
</body>
</html>
