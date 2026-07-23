<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Search Train Schedules</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="customer_dashboard.jsp">&larr; Back to Dashboard</a>
            <a href="../logout.jsp" style="float:right;">Logout</a>
        </div>
        <h2>Search Train Schedules</h2>
        <form action="search_schedules.jsp" method="GET">
            <div class="form-group">
                <label for="origin">Origin Station:</label>
                <select name="origin" id="origin" required>
                    <option value="">Select Origin</option>
                    <%
                        Connection con = null;
                        Statement st = null;
                        ResultSet rs = null;
                        try {
                            con = DatabaseConnection.getConnection();
                            st = con.createStatement();
                            rs = st.executeQuery("SELECT station_id, name FROM STATION ORDER BY name");
                            while(rs.next()) {
                                String selected = String.valueOf(rs.getInt("station_id")).equals(request.getParameter("origin")) ? "selected" : "";
                                out.println("<option value='" + rs.getInt("station_id") + "' " + selected + ">" + rs.getString("name") + "</option>");
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            if(rs != null) rs.close();
                            if(st != null) st.close();
                        }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label for="destination">Destination Station:</label>
                <select name="destination" id="destination" required>
                    <option value="">Select Destination</option>
                    <%
                        try {
                            st = con.createStatement();
                            rs = st.executeQuery("SELECT station_id, name FROM STATION ORDER BY name");
                            while(rs.next()) {
                                String selected = String.valueOf(rs.getInt("station_id")).equals(request.getParameter("destination")) ? "selected" : "";
                                out.println("<option value='" + rs.getInt("station_id") + "' " + selected + ">" + rs.getString("name") + "</option>");
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            if(rs != null) rs.close();
                            if(st != null) st.close();
                        }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label for="travel_date">Date of Travel:</label>
                <input type="date" name="travel_date" id="travel_date" value="<%= request.getParameter("travel_date") != null ? request.getParameter("travel_date") : "" %>" required>
            </div>
            
            <!-- Preserve sorting parameters -->
            <input type="hidden" name="sort" value="<%= request.getParameter("sort") != null ? request.getParameter("sort") : "departure_datetime" %>">
            
            <input type="submit" value="Search">
        </form>

        <%
            String originStr = request.getParameter("origin");
            String destStr = request.getParameter("destination");
            String travelDate = request.getParameter("travel_date");
            String sortBy = request.getParameter("sort");
            
            if (sortBy == null || sortBy.isEmpty()) {
                sortBy = "origin_departure"; // default sort
            }

            // Map allowed sort fields to actual column expressions to prevent SQL injection
            String orderClause = "o.departure_datetime ASC";
            if ("arrival_datetime".equals(sortBy)) {
                orderClause = "d.arrival_datetime ASC";
            } else if ("fare".equals(sortBy)) {
                orderClause = "tl.base_fare ASC"; // We will calculate fare dynamically later, but sorting by base_fare is fine for now
            }

            if (originStr != null && destStr != null && travelDate != null && !originStr.isEmpty() && !destStr.isEmpty() && !travelDate.isEmpty()) {
                if (originStr.equals(destStr)) {
                    out.println("<p style='color:red;'>Origin and destination cannot be the same.</p>");
                } else {
                    PreparedStatement pst = null;
                    ResultSet rsSearch = null;
                    try {
                        String query = "SELECT ts.schedule_id, ts.train_id, ts.line_name, tl.base_fare, " +
                                       "o.departure_datetime as origin_departure, " +
                                       "d.arrival_datetime as dest_arrival " +
                                       "FROM TRAIN_SCHEDULE ts " +
                                       "JOIN TRANSIT_LINE tl ON ts.line_name = tl.line_name " +
                                       "JOIN STOPS_AT o ON ts.schedule_id = o.schedule_id " +
                                       "JOIN STOPS_AT d ON ts.schedule_id = d.schedule_id " +
                                       "WHERE o.station_id = ? AND d.station_id = ? " +
                                       "AND o.stop_sequence < d.stop_sequence " +
                                       "AND DATE(o.departure_datetime) = ? " +
                                       "ORDER BY " + orderClause;
                        
                        pst = con.prepareStatement(query);
                        pst.setInt(1, Integer.parseInt(originStr));
                        pst.setInt(2, Integer.parseInt(destStr));
                        pst.setString(3, travelDate);
                        
                        rsSearch = pst.executeQuery();
                        
                        out.println("<h3>Search Results</h3>");
                        out.println("<table>");
                        
                        // Create sortable headers
                        String basePath = "search_schedules.jsp?origin=" + originStr + "&destination=" + destStr + "&travel_date=" + travelDate + "&sort=";
                        
                        out.println("<tr>");
                        out.println("<th>Train ID</th>");
                        out.println("<th>Transit Line</th>");
                        out.println("<th><a href='" + basePath + "departure_datetime'>Departure</a></th>");
                        out.println("<th><a href='" + basePath + "arrival_datetime'>Arrival</a></th>");
                        out.println("<th><a href='" + basePath + "fare'>Fare (Base)</a></th>");
                        out.println("<th>Action</th>");
                        out.println("</tr>");
                        
                        boolean found = false;
                        while(rsSearch.next()) {
                            found = true;
                            out.println("<tr>");
                            out.println("<td>" + rsSearch.getString("train_id") + "</td>");
                            out.println("<td>" + rsSearch.getString("line_name") + "</td>");
                            out.println("<td>" + rsSearch.getString("origin_departure") + "</td>");
                            out.println("<td>" + rsSearch.getString("dest_arrival") + "</td>");
                            out.println("<td>$" + rsSearch.getInt("base_fare") + "</td>"); // Actual fare calculation happens during reservation
                            out.println("<td><a href='view_schedule_details.jsp?schedule_id=" + rsSearch.getInt("schedule_id") + "'>View Details</a> | <a href='make_reservation.jsp?schedule_id=" + rsSearch.getInt("schedule_id") + "&origin=" + originStr + "&dest=" + destStr + "&date=" + travelDate + "'>Book</a></td>");
                            out.println("</tr>");
                        }
                        
                        if (!found) {
                            out.println("<tr><td colspan='6'>No trains found for this route and date.</td></tr>");
                        }
                        out.println("</table>");
                    } catch(Exception e) {
                        e.printStackTrace();
                        out.println("<p style='color:red;'>An error occurred while searching.</p>");
                    } finally {
                        if(rsSearch != null) rsSearch.close();
                        if(pst != null) pst.close();
                    }
                }
            }
            if (con != null) con.close();
        %>
    </div>
</body>
</html>
