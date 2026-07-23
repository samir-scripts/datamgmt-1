<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer_rep".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    String action = request.getParameter("action");
    if ("delete".equals(action)) {
        String scheduleId = request.getParameter("id");
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            String query = "DELETE FROM TRAIN_SCHEDULE WHERE schedule_id = ?";
            pst = con.prepareStatement(query);
            pst.setInt(1, Integer.parseInt(scheduleId));
            pst.executeUpdate();
            response.sendRedirect("manage_schedules.jsp?success=Schedule deleted.");
            return;
        } catch(Exception e) {
            response.sendRedirect("manage_schedules.jsp?error=Failed to delete schedule.");
            return;
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Train Schedules</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="rep_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Manage Train Schedules</h2>
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) out.println("<div class='success'>" + successMsg + "</div>");
            if (errorMsg != null) out.println("<div class='error'>" + errorMsg + "</div>");
        %>
        
        <table>
            <tr><th>Schedule ID</th><th>Train ID</th><th>Transit Line</th><th>Departure</th><th>Arrival</th><th>Action</th></tr>
            <%
                Connection con = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    st = con.createStatement();
                    rs = st.executeQuery("SELECT * FROM TRAIN_SCHEDULE");
                    while(rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getInt("schedule_id") + "</td>");
                        out.println("<td>" + rs.getString("train_id") + "</td>");
                        out.println("<td>" + rs.getString("line_name") + "</td>");
                        out.println("<td>" + rs.getString("departure_datetime") + "</td>");
                        out.println("<td>" + rs.getString("arrival_datetime") + "</td>");
                        out.println("<td><a href='manage_schedules.jsp?action=delete&id=" + rs.getInt("schedule_id") + "' onclick=\"return confirm('Delete this schedule and all its stops/reservations?');\">Delete</a></td>");
                        out.println("</tr>");
                    }
                } catch(Exception e) { e.printStackTrace(); } finally {
                    if (rs != null) rs.close();
                    if (st != null) st.close();
                    if (con != null) con.close();
                }
            %>
        </table>
        <!-- Add schedule form omitted for brevity of first draft -->
        <p><em>(Add schedule functionality to be implemented in v2)</em></p>
    </div>
</body>
</html>
