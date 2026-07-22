<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    String scheduleId = request.getParameter("schedule_id");
    if (scheduleId == null || scheduleId.isEmpty()) {
        response.sendRedirect("search_schedules.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Schedule Details</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: #fff; max-width: 800px; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); margin: auto; }
        h2 { color: #333; }
        .nav-links { margin-bottom: 20px; }
        .nav-links a { margin-right: 15px; text-decoration: none; color: #007bff; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="search_schedules.jsp">&larr; Back to Search</a>
            <a href="../logout.jsp" style="float:right;">Logout</a>
        </div>
        
        <%
            Connection con = null;
            PreparedStatement pstInfo = null;
            PreparedStatement pstStops = null;
            ResultSet rsInfo = null;
            ResultSet rsStops = null;
            
            try {
                con = DatabaseConnection.getConnection();
                
                // Get basic schedule info
                String infoQuery = "SELECT ts.train_id, ts.line_name, tl.base_fare " +
                                   "FROM TRAIN_SCHEDULE ts " +
                                   "JOIN TRANSIT_LINE tl ON ts.line_name = tl.line_name " +
                                   "WHERE ts.schedule_id = ?";
                pstInfo = con.prepareStatement(infoQuery);
                pstInfo.setInt(1, Integer.parseInt(scheduleId));
                rsInfo = pstInfo.executeQuery();
                
                if (rsInfo.next()) {
                    out.println("<h2>Schedule Details (Train: " + rsInfo.getString("train_id") + ")</h2>");
                    out.println("<p><strong>Transit Line:</strong> " + rsInfo.getString("line_name") + "</p>");
                    out.println("<p><strong>Base Fare:</strong> $" + rsInfo.getInt("base_fare") + "</p>");
                    
                    // Get stops
                    String stopsQuery = "SELECT st.name, sa.arrival_datetime, sa.departure_datetime, sa.stop_sequence " +
                                        "FROM STOPS_AT sa " +
                                        "JOIN STATION st ON sa.station_id = st.station_id " +
                                        "WHERE sa.schedule_id = ? " +
                                        "ORDER BY sa.stop_sequence ASC";
                    pstStops = con.prepareStatement(stopsQuery);
                    pstStops.setInt(1, Integer.parseInt(scheduleId));
                    rsStops = pstStops.executeQuery();
                    
                    out.println("<table>");
                    out.println("<tr><th>Stop #</th><th>Station</th><th>Arrival Time</th><th>Departure Time</th></tr>");
                    
                    while(rsStops.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rsStops.getInt("stop_sequence") + "</td>");
                        out.println("<td>" + rsStops.getString("name") + "</td>");
                        out.println("<td>" + (rsStops.getString("arrival_datetime") != null ? rsStops.getString("arrival_datetime") : "N/A (Origin)") + "</td>");
                        out.println("<td>" + (rsStops.getString("departure_datetime") != null ? rsStops.getString("departure_datetime") : "N/A (Destination)") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                } else {
                    out.println("<p>Invalid Schedule ID.</p>");
                }
            } catch(Exception e) {
                e.printStackTrace();
                out.println("<p style='color:red;'>An error occurred while fetching details.</p>");
            } finally {
                if(rsStops != null) rsStops.close();
                if(rsInfo != null) rsInfo.close();
                if(pstStops != null) pstStops.close();
                if(pstInfo != null) pstInfo.close();
                if(con != null) con.close();
            }
        %>
    </div>
</body>
</html>
