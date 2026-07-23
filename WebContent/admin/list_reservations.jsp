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
    <title>List Reservations</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="admin_dashboard.jsp">&larr; Dashboard</a>
        </div>
        <h2>List Reservations</h2>
        
        <form action="list_reservations.jsp" method="GET">
            <div class="form-group">
                <input type="text" name="customerName" placeholder="Customer Name (e.g., John)" value="<%= request.getParameter("customerName") != null ? request.getParameter("customerName") : "" %>">
            </div>
            <div class="form-group">
                <input type="text" name="transitLine" placeholder="Transit Line (e.g., Northeast)" value="<%= request.getParameter("transitLine") != null ? request.getParameter("transitLine") : "" %>">
            </div>
            <input type="submit" value="Filter">
            <a href="list_reservations.jsp" style="margin-left:10px;">Clear</a>
        </form>

        <table>
            <tr>
                <th>Res. #</th><th>Date</th><th>Customer Name</th><th>Transit Line</th><th>Origin</th><th>Destination</th><th>Fare</th><th>Status</th>
            </tr>
            <%
                String customerName = request.getParameter("customerName");
                String transitLine = request.getParameter("transitLine");
                
                Connection con = null;
                PreparedStatement pst = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    
                    String query = "SELECT r.reservation_number, r.reservation_date, r.total_fare, r.status, " +
                                   "c.first_name, c.last_name, ts.line_name, o.name as origin_name, d.name as dest_name " +
                                   "FROM RESERVATION r " +
                                   "JOIN CUSTOMER c ON r.cid = c.cid " +
                                   "JOIN TRAIN_SCHEDULE ts ON r.schedule_id = ts.schedule_id " +
                                   "JOIN STATION o ON r.origin_station_id = o.station_id " +
                                   "JOIN STATION d ON r.destination_station_id = d.station_id WHERE 1=1 ";
                    
                    if (customerName != null && !customerName.isEmpty()) {
                        query += "AND (c.first_name LIKE ? OR c.last_name LIKE ?) ";
                    }
                    if (transitLine != null && !transitLine.isEmpty()) {
                        query += "AND ts.line_name LIKE ? ";
                    }
                    
                    query += "ORDER BY r.reservation_date DESC";
                    
                    pst = con.prepareStatement(query);
                    int paramIndex = 1;
                    
                    if (customerName != null && !customerName.isEmpty()) {
                        pst.setString(paramIndex++, "%" + customerName + "%");
                        pst.setString(paramIndex++, "%" + customerName + "%");
                    }
                    if (transitLine != null && !transitLine.isEmpty()) {
                        pst.setString(paramIndex++, "%" + transitLine + "%");
                    }
                    
                    rs = pst.executeQuery();
                    boolean found = false;
                    while(rs.next()) {
                        found = true;
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt("reservation_number") + "</td>");
                        out.println("<td>" + rs.getString("reservation_date") + "</td>");
                        out.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
                        out.println("<td>" + rs.getString("line_name") + "</td>");
                        out.println("<td>" + rs.getString("origin_name") + "</td>");
                        out.println("<td>" + rs.getString("dest_name") + "</td>");
                        out.println("<td>$" + rs.getInt("total_fare") + "</td>");
                        out.println("<td>" + rs.getString("status") + "</td>");
                        out.println("</tr>");
                    }
                    if (!found) out.println("<tr><td colspan='8'>No reservations found.</td></tr>");
                    
                } catch(Exception e) { e.printStackTrace(); } finally {
                    if (rs != null) rs.close();
                    if (pst != null) pst.close();
                    if (con != null) con.close();
                }
            %>
        </table>
    </div>
</body>
</html>
