<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    int cid = (Integer) session.getAttribute("userId");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String question = request.getParameter("question");
        if (question != null && !question.trim().isEmpty()) {
            Connection con = null;
            PreparedStatement pst = null;
            try {
                con = DatabaseConnection.getConnection();
                String query = "INSERT INTO CUSTOMER_QUESTION (cid, question_text, question_datetime) VALUES (?, ?, NOW())";
                pst = con.prepareStatement(query);
                pst.setInt(1, cid);
                pst.setString(2, question);
                pst.executeUpdate();
                response.sendRedirect("ask_question.jsp?success=Question submitted successfully.");
                return;
            } catch(Exception e) {
                e.printStackTrace();
                response.sendRedirect("ask_question.jsp?error=Failed to submit question.");
                return;
            } finally {
                if(pst != null) pst.close();
                if(con != null) con.close();
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Service</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="customer_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Ask Customer Service</h2>
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) out.println("<div class='success'>" + successMsg + "</div>");
            if (errorMsg != null) out.println("<div class='error'>" + errorMsg + "</div>");
        %>
        
        <form action="ask_question.jsp" method="POST">
            <textarea name="question" rows="4" placeholder="Enter your question here..." required></textarea><br>
            <input type="submit" value="Submit Question">
        </form>

        <hr style="margin: 30px 0;">
        <h2>My Previous Questions</h2>
        <%
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            try {
                con = DatabaseConnection.getConnection();
                String query = "SELECT question_text, answer_text, question_datetime, answer_datetime FROM CUSTOMER_QUESTION WHERE cid = ? ORDER BY question_datetime DESC";
                pst = con.prepareStatement(query);
                pst.setInt(1, cid);
                rs = pst.executeQuery();
                
                boolean found = false;
                while(rs.next()) {
                    found = true;
                    out.println("<div class='qna'>");
                    out.println("<strong>Q (" + rs.getString("question_datetime") + "):</strong> " + rs.getString("question_text"));
                    if (rs.getString("answer_text") != null) {
                        out.println("<div class='answer'><strong>A (" + rs.getString("answer_datetime") + "):</strong> " + rs.getString("answer_text") + "</div>");
                    } else {
                        out.println("<div class='answer'><em>Waiting for a representative to reply...</em></div>");
                    }
                    out.println("</div>");
                }
                if (!found) {
                    out.println("<p>You have not asked any questions yet.</p>");
                }
            } catch(Exception e) { e.printStackTrace(); } finally {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (con != null) con.close();
            }
        %>
    </div>
</body>
</html>
