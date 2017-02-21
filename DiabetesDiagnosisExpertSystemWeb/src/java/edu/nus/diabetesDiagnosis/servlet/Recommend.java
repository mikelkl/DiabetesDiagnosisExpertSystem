/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.nus.diabetesDiagnosis.servlet;

import edu.nus.diabetesDiagnosis.entity.PersonInfo;
import edu.nus.diabetesDiagnosis.entity.RiskFactor;
import edu.nus.diabetesDiagnosis.entity.Symptom;
import edu.nus.diabetesDiagnosis.entity.Test;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Administrator
 */
public class Recommend extends HttpServlet {
    private PersonInfo personInfo;
    private Test test;
    private RiskFactor riskFactor;
    private Symptom symptom;
    
    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String age = request.getParameter("age");
        String gender = request.getParameter("gender");
        String pregnant = request.getParameter("pregnant");
        String OGTT = request.getParameter("OGTT");
        String FPG = request.getParameter("FPG");
        String CPG = request.getParameter("CPG");
        String obesity = request.getParameter("obesity");
        String bloodPressure = request.getParameter("bloodPressure");
        String familyHistory = request.getParameter("familyHistory");
        String TG = request.getParameter("TG");
        String lowActivity = request.getParameter("lowActivity");
        String IGT = request.getParameter("IGT");
        String FPGResult = request.getParameter("FPGResult");
        String gestational = request.getParameter("gestational");
        String POS = request.getParameter("POS");
        String headache = request.getParameter("headache");
        String BV = request.getParameter("BV");
        String EU = request.getParameter("EU");
        String polydipsia = request.getParameter("polydipsia");
        String LC = request.getParameter("LC");
        String NV = request.getParameter("NV");
        String polyphagia = request.getParameter("polyphagia");
        String tiredness = request.getParameter("tiredness");
        String LW = request.getParameter("LW");
        String FST = request.getParameter("FST");
        String FI = request.getParameter("FI");
        String sensation = request.getParameter("sensation");
        String coldWweat = request.getParameter("coldWweat");
        
        response.setContentType("application/json");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.print("{\"status\": \"success\"}");
        }
    }
}
