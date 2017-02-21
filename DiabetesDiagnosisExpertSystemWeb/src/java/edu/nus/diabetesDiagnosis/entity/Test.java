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
public class Test {
    private String OGTT;
    private String FPG;
    private String CPG;

    public Test(String OGTT, String FPG, String CPG) {
        this.OGTT = OGTT;
        this.FPG = FPG;
        this.CPG = CPG;
    }

    public String getOGTT() {
        return OGTT;
    }

    public void setOGTT(String OGTT) {
        this.OGTT = OGTT;
    }

    public String getFPG() {
        return FPG;
    }

    public void setFPG(String FPG) {
        this.FPG = FPG;
    }

    public String getCPG() {
        return CPG;
    }

    public void setCPG(String CPG) {
        this.CPG = CPG;
    }
}
