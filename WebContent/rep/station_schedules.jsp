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
    <title>Station Schedules</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="rep_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Train Schedules by Station</h2>
        
        <form action="station_schedules.jsp" method="GET">
            <div class="form-group">
                <label for="station_id">Select Station:</label>
                <select name="station_id" id="station_id" required>
                    <option value="">-- Select Station --</option>
                    <%
                        Connection con = null;
                        Statement st = null;
                        ResultSet rsStations = null;
                        try {
                            con = DatabaseConnection.getConnection();
                            st = con.createStatement();
                            rsStations = st.executeQuery("SELECT station_id, name FROM STATION ORDER BY name");
                            while(rsStations.next()) {
                                String selected = String.valueOf(rsStations.getInt("station_id")).equals(request.getParameter("station_id")) ? "selected" : "";
                                out.println("<option value='" + rsStations.getInt("station_id") + "' " + selected + ">" + rsStations.getString("name") + "</option>");
                            }
                        } catch(Exception e) { e.printStackTrace(); } finally {
                            if(rsStations != null) rsStations.close();
                            if(st != null) st.close();
                        }
                    %>
                </select>
                <input type="submit" value="View Schedules">
            </div>
        </form>

        <%
            String stationIdStr = request.getParameter("station_id");
            if (stationIdStr != null && !stationIdStr.isEmpty()) {
                PreparedStatement pst = null;
                ResultSet rs = null;
                try {
                    String query = "SELECT ts.schedule_id, ts.train_id, ts.line_name, sa.arrival_datetime, sa.departure_datetime " +
                                   "FROM STOPS_AT sa " +
                                   "JOIN TRAIN_SCHEDULE ts ON sa.schedule_id = ts.schedule_id " +
                                   "WHERE sa.station_id = ? " +
                                   "ORDER BY sa.departure_datetime ASC, sa.arrival_datetime ASC";
                    pst = con.prepareStatement(query);
                    pst.setInt(1, Integer.parseInt(stationIdStr));
                    rs = pst.executeQuery();
                    
                    out.println("<table>");
                    out.println("<tr><th>Train ID</th><th>Transit Line</th><th>Arrival Time</th><th>Departure Time</th></tr>");
                    
                    boolean found = false;
                    while(rs.next()) {
                        found = true;
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("train_id") + "</td>");
                        out.println("<td>" + rs.getString("line_name") + "</td>");
                        out.println("<td>" + (rs.getString("arrival_datetime") != null ? rs.getString("arrival_datetime") : "Origin") + "</td>");
                        out.println("<td>" + (rs.getString("departure_datetime") != null ? rs.getString("departure_datetime") : "Destination") + "</td>");
                        out.println("</tr>");
                    }
                    if (!found) {
                        out.println("<tr><td colspan='4'>No schedules found for this station.</td></tr>");
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
