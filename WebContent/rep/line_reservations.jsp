<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
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
    <title>Transit Line Reservations</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="rep_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Customers on a Transit Line by Date</h2>
        
        <form action="line_reservations.jsp" method="GET">
            <div class="form-group">
                <select name="line_name" required>
                    <option value="">-- Select Transit Line --</option>
                    <%
                        Connection con = null;
                        Statement st = null;
                        ResultSet rsLines = null;
                        try {
                            con = DatabaseConnection.getConnection();
                            st = con.createStatement();
                            rsLines = st.executeQuery("SELECT line_name FROM TRANSIT_LINE ORDER BY line_name");
                            while(rsLines.next()) {
                                String selected = rsLines.getString("line_name").equals(request.getParameter("line_name")) ? "selected" : "";
                                out.println("<option value='" + rsLines.getString("line_name") + "' " + selected + ">" + rsLines.getString("line_name") + "</option>");
                            }
                        } catch(Exception e) { e.printStackTrace(); } finally {
                            if(rsLines != null) rsLines.close();
                            if(st != null) st.close();
                        }
                    %>
                </select>
            </div>
            <div class="form-group">
                <input type="date" name="travel_date" value="<%= request.getParameter("travel_date") != null ? request.getParameter("travel_date") : "" %>" required>
            </div>
            <input type="submit" value="View Customers">
        </form>

        <%
            String lineName = request.getParameter("line_name");
            String travelDate = request.getParameter("travel_date");
            
            if (lineName != null && travelDate != null && !lineName.isEmpty() && !travelDate.isEmpty()) {
                PreparedStatement pst = null;
                ResultSet rs = null;
                try {
                    String query = "SELECT c.first_name, c.last_name, c.email, r.reservation_number " +
                                   "FROM RESERVATION r " +
                                   "JOIN CUSTOMER c ON r.cid = c.cid " +
                                   "JOIN TRAIN_SCHEDULE ts ON r.schedule_id = ts.schedule_id " +
                                   "WHERE ts.line_name = ? AND r.reservation_date = ?";
                    pst = con.prepareStatement(query);
                    pst.setString(1, lineName);
                    pst.setDate(2, java.sql.Date.valueOf(travelDate));
                    rs = pst.executeQuery();
                    
                    out.println("<table>");
                    out.println("<tr><th>Customer Name</th><th>Email</th><th>Reservation #</th></tr>");
                    
                    boolean found = false;
                    while(rs.next()) {
                        found = true;
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
                        out.println("<td>" + rs.getString("email") + "</td>");
                        out.println("<td>" + rs.getInt("reservation_number") + "</td>");
                        out.println("</tr>");
                    }
                    if (!found) {
                        out.println("<tr><td colspan='3'>No reservations found for this line on this date.</td></tr>");
                    }
                    out.println("</table>");
                } catch(Exception e) { e.printStackTrace(); } finally {
                    if (rs != null) rs.close();
                    if (pst != null) pst.close();
                }
            }
            if (con != null) con.close();
        %>
    </div>
</body>
</html>
