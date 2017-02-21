/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.nus.diabetesDiagnosis.entity;

/**
 *
 * @author Administrator
 */
public class RiskFactor {
    private String obesity;
    private String bloodPressure;
    private String familyHistory;
    private String TG;
    private String lowActivity;
    private String IGT;
    private String FPGResult;
    private String gestational;
    private String POS;

    public RiskFactor(String obesity, String bloodPressure, String familyHistory, String TG, String lowActivity, String IGT, String FPGResult, String gestational, String POS) {
        this.obesity = obesity;
        this.bloodPressure = bloodPressure;
        this.familyHistory = familyHistory;
        this.TG = TG;
        this.lowActivity = lowActivity;
        this.IGT = IGT;
        this.FPGResult = FPGResult;
        this.gestational = gestational;
        this.POS = POS;
    }
    
    public String getObesity() {
        return obesity;
    }

    public void setObesity(String obesity) {
        this.obesity = obesity;
    }

    public String getBloodPressure() {
        return bloodPressure;
    }

    public void setBloodPressure(String bloodPressure) {
        this.bloodPressure = bloodPressure;
    }

    public String getFamilyHistory() {
        return familyHistory;
    }

    public void setFamilyHistory(String familyHistory) {
        this.familyHistory = familyHistory;
    }

    public String getTG() {
        return TG;
    }

    public void setTG(String TG) {
        this.TG = TG;
    }

    public String getLowActivity() {
        return lowActivity;
    }

    public void setLowActivity(String lowActivity) {
        this.lowActivity = lowActivity;
    }

    public String getIGT() {
        return IGT;
    }

    public void setIGT(String IGT) {
        this.IGT = IGT;
    }

    public String getFPGResult() {
        return FPGResult;
    }

    public void setFPGResult(String FPGResult) {
        this.FPGResult = FPGResult;
    }

    public String getGestational() {
        return gestational;
    }

    public void setGestational(String gestational) {
        this.gestational = gestational;
    }

    public String getPOS() {
        return POS;
    }

    public void setPOS(String POS) {
        this.POS = POS;
    }
    
}
