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

import net.sf.clipsrules.jni.*;


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
        String age = request.getParameter("age");
        String gender = request.getParameter("gender");
        String pregnant = request.getParameter("pregnant");
        String OGTT = request.getParameter("OGTT");
        // clips numberp will automatically convert null value to 0, thus, assign the numeric variables a string value for easy judge.
        if (OGTT.equals("")) {
            OGTT = "na";
        }
        String FPG = request.getParameter("FPG");
        if (FPG.equals("")) {
            FPG = "na";
        }
        String CPG = request.getParameter("CPG");
        if (CPG.equals("")) {
            CPG = "na";
        }
        String obesity = request.getParameter("obesity");
        if (obesity.equals("")) {
            obesity = "na";
        }
        String bloodPressure = request.getParameter("bloodPressure");
        String familyHistory = request.getParameter("familyHistory");
        String TG = request.getParameter("TG");
        String lowActivity = request.getParameter("lowActivity");
        String IGT = request.getParameter("IGT");
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
        String coldSweat = request.getParameter("coldSweat");
        
        response.setContentType("application/json");
        
        Environment clips = new Environment();
        clips.load("E:\\University\\NUS\\Semester_1\\INTELLIGENT_SYSTEMS_AND_TECHNIQUES_FOR_BUSINESS_ANALYTICS\\CA\\DiabetesDiagnosisExpertSystem\\diagnosis1.CLP");

        clips.reset();
//        clips.assertString("(info-gender " + gender + ")");
//        if (gender.equals("female")) {
//            clips.assertString("(info-pregnant " + pregnant + ")");
//        }
//        clips.eval("(bind ?*age* " + age + ")");
//        clips.assertString("(info-age " + age + ")");
//        clips.eval("(bind ?*ogtt* " + OGTT + ")");
//        clips.eval("(bind ?*fpg* " + FPG + ")");
//        clips.eval("(bind ?*cpg* " + CPG + ")");
//        clips.eval("(bind ?*bmi* " + obesity + ")");
//        clips.assertString("(factor-bp " + bloodPressure + ")");
//        clips.assertString("(factor-history " + familyHistory + ")");
//        clips.assertString("(factor-tg " + TG + ")");
//        clips.assertString("(factor-gestational-history " + gestational + ")");
//        clips.assertString("(factor-activity " + lowActivity + ")");
//        clips.assertString("(factor-gt " + IGT + ")");
//        clips.assertString("(factor-pos " + POS + ")");
//        clips.assertString("(symp-headache " + headache + ")");
//        clips.assertString("(symp-blur " + BV + ")");
//        clips.assertString("(symp-eu " + EU + ")");
//        clips.assertString("(symp-polydipsia " + polydipsia + ")");
//        clips.assertString("(symp-lc " + LC + ")");
//        clips.assertString("(symp-nausea " + NV + ")");
//        clips.assertString("(symp-polyphagia " + polyphagia + ")");
//        clips.assertString("(symp-tiredness " + tiredness + ")");
//        clips.assertString("(symp-lw " + LW + ")");
//        clips.assertString("(symp-fraction " + FST + ")");
//        clips.assertString("(symp-infection " + FI + ")");
//        clips.assertString("(symp-ls " + sensation + ")");
//        clips.assertString("(symp-cs " + coldSweat + ")");

        clips.eval("(bind ?*gender* " + gender + ")");
        clips.eval("(bind ?*pregnant-input* " + pregnant + ")");
        clips.eval("(bind ?*age* " + age + ")");
        clips.eval("(bind ?*ogtt* " + OGTT + ")");
        clips.eval("(bind ?*fpg* " + FPG + ")");
        clips.eval("(bind ?*cpg* " + CPG + ")");
        clips.eval("(bind ?*bmi* " + obesity + ")");
        clips.eval("(bind ?*bp* " + bloodPressure + ")");
        clips.eval("(bind ?*fh* " + familyHistory + ")");
        clips.eval("(bind ?*triglycerides* " + TG + ")");
        clips.eval("(bind ?*gh* " + gestational + ")");
        clips.eval("(bind ?*activity* " + lowActivity + ")");
        clips.eval("(bind ?*gt* " + IGT + ")");
        clips.eval("(bind ?*pos* " + POS + ")");
        clips.eval("(bind ?*headache* " + headache + ")");
        clips.eval("(bind ?*blur* " + BV + ")");
        clips.eval("(bind ?*eu* " + EU + ")");
        clips.eval("(bind ?*polydipsia* " + polydipsia + ")");
        clips.eval("(bind ?*lc* " + LC + ")");
        clips.eval("(bind ?*nausea* " + NV + ")");
        clips.eval("(bind ?*polyphagia* " + polyphagia + ")");
        clips.eval("(bind ?*tiredness* " + tiredness + ")");
        clips.eval("(bind ?*lw* " + LW + ")");
        clips.eval("(bind ?*fraction* " + FST + ")");
        clips.eval("(bind ?*infection* " + FI + ")");
        clips.eval("(bind ?*ls* " + sensation + ")");
        clips.eval("(bind ?*cs* " + coldSweat + ")");

        clips.run();
        String evalStr = "(find-all-facts ((?f current_goal)) TRUE)";
        String result = "{";
        try {
            MultifieldValue pv = (MultifieldValue) clips.eval(evalStr);
//            MultifieldValue pv2 = (MultifieldValue) clips.eval("(find-all-facts ((?f result-test)) TRUE)");
//            String test1 = clips.eval("(find-all-facts ((?f result-test)) TRUE)").toString();
//            String test2 = clips.eval("(find-all-facts ((?f result-symtom)) TRUE)").toString();
//            String test3 = clips.eval("(find-all-facts ((?f result-factor)) TRUE)").toString();
            int tNum = pv.size();
            if (tNum == 0) return;
            FactAddressValue fv;
            
            for (int i=0; i<tNum; i++) {
                fv = (FactAddressValue) pv.get(i);
                String goal = fv.getFactSlot("goal").toString();
                String cf = fv.getFactSlot("cf").toString();
                result += ("\"" + goal + "\":" + cf + ",");
                System.out.println(goal + "  " + cf);
            }
            result = result.substring(0,result.length()-1);
            result += "}";
        } catch (Exception ex) {
            System.out.println(ex);
        }
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.print(result);
        }
    }
}
