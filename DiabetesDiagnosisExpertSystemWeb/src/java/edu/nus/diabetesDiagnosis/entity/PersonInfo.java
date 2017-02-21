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
public class PersonInfo {
    private String name;
    private String age;
    private String gender;
    private String pregnant;

    public PersonInfo(String name, String age, String gender, String pregnant) {
        this.name = name;
        this.age = age;
        this.gender = gender;
        this.pregnant = pregnant;
    }
    
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAge() {
        return age;
    }

    public void setAge(String age) {
        this.age = age;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getPregnant() {
        return pregnant;
    }

    public void setPregnant(String pregnant) {
        this.pregnant = pregnant;
    }
    
}
