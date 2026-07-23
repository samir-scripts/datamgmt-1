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
    <title>Revenue Reports</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="admin_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Revenue by Transit Line</h2>
        <table>
            <tr><th>Transit Line</th><th>Total Revenue</th></tr>
            <%
                Connection con = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    st = con.createStatement();
                    String query = "SELECT ts.line_name, SUM(r.total_fare) as revenue " +
                                   "FROM RESERVATION r " +
                                   "JOIN TRAIN_SCHEDULE ts ON r.schedule_id = ts.schedule_id " +
                                   "GROUP BY ts.line_name " +
                                   "ORDER BY revenue DESC";
                    rs = st.executeQuery(query);
                    while(rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("line_name") + "</td>");
                        out.println("<td>$" + (rs.getString("revenue") == null ? "0" : rs.getString("revenue")) + "</td>");
                        out.println("</tr>");
                    }
                } catch(Exception e) { e.printStackTrace(); }
            %>
        </table>

        <h2>Revenue by Customer</h2>
        <table>
            <tr><th>Customer Name</th><th>Total Revenue</th></tr>
            <%
                try {
                    String query = "SELECT c.first_name, c.last_name, SUM(r.total_fare) as revenue " +
                                   "FROM RESERVATION r " +
                                   "JOIN CUSTOMER c ON r.cid = c.cid " +
                                   "GROUP BY c.cid " +
                                   "ORDER BY revenue DESC";
                    rs = st.executeQuery(query);
                    while(rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
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
