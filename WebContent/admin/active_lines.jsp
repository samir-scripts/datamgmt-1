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
    <title>Active Lines</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="admin_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Top 5 Most Active Transit Lines (By Reservations)</h2>
        <table>
            <tr><th>Rank</th><th>Transit Line</th><th>Number of Reservations</th></tr>
            <%
                Connection con = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    st = con.createStatement();
                    String query = "SELECT ts.line_name, COUNT(r.reservation_number) as num_reservations " +
                                   "FROM RESERVATION r " +
                                   "JOIN TRAIN_SCHEDULE ts ON r.schedule_id = ts.schedule_id " +
                                   "GROUP BY ts.line_name " +
                                   "ORDER BY num_reservations DESC LIMIT 5";
                    rs = st.executeQuery(query);
                    int rank = 1;
                    while(rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rank++ + "</td>");
                        out.println("<td>" + rs.getString("line_name") + "</td>");
                        out.println("<td>" + rs.getInt("num_reservations") + "</td>");
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
