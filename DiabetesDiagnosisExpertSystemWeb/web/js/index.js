/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

// attribute
let name;
let age;
let gender;
let pregnant;
let ogtt;
let fpg;
let cpg;
let obesity;
let bloodPressure;
let familyHistory;
let TG;
let lowActivity;
let IGT;
let FPGResult;
let gestational;
let POS;

let next = document.querySelector("#next"); // next button
let container = document.querySelector("section"); // top container
let fieldsets = document.querySelectorAll("fieldset"); // select all question fields
let count = 0;

function nextHandler() {
    let errorSpan = document.createElement("span");
    errorSpan.classList.add('lgt-error');
    
    switch(count) {
        case 0:
            let testField = fieldsets[1];

            // pregant women don't need do following test
            if (pregnant === 'no') {
                // append FPG div
                let FPGDIV = document.createElement("div");
                FPGDIV.class = "lgt-input-group";
                FPGDIV.textContent = "FPG Value: ";
                let FPGInput = document.createElement("input");
                FPGInput.name = "fpg";
                FPGInput.type = "text";
                // bind listen event
                FPGInput.onblur = function() {
                    getValue(this);
                };
                FPGInput.autocomplete = "off";
                FPGDIV.appendChild(FPGInput);
                FPGDIV.appendChild(errorSpan);
                testField.appendChild(FPGDIV);

                // append CPG div
                let CPGDIV = document.createElement("div");
                CPGDIV.class = "lgt-input-group";
                CPGDIV.textContent = "CPG Value: ";
                let CPGInput = document.createElement("input");
                CPGInput.name = "cpg";
                CPGInput.type = "text";
                // bind listen event
                CPGInput.onblur = function() {
                    getValue(this);
                };
                CPGInput.autocomplete = "off";
                CPGDIV.appendChild(CPGInput);
                CPGDIV.appendChild(errorSpan);
                testField.appendChild(CPGDIV);
            }
            break;
        case 1:
            let riskFactorField = fieldsets[2];

            // the follwing questions only for women
            if (gender === 'female') {
                let yesText = document.createTextNode(" Yes");
                let noText = document.createTextNode(" No");
                
                // append History of gestational diabetes or Having Baby with over 4 Kg weight (female only) div
                let gestationalDIV = document.createElement("div");
                gestationalDIV.class = "lgt-input-group";
                gestationalDIV.textContent = "History of gestational diabetes or Having Baby with over 4 Kg weight (female only): ";
                let gestationalInputRadio1 = document.createElement("input");
                gestationalInputRadio1.name = "gestational";
                gestationalInputRadio1.type = "radio";
                gestationalInputRadio1.value = "yes";
                // bind listen event
                gestationalInputRadio1.onblur = function() {
                    getValue(this);
                };
                gestationalDIV.appendChild(gestationalInputRadio1);
                gestationalDIV.appendChild(yesText);
                
                let gestationalInputRadio2 = document.createElement("input");
                gestationalInputRadio2.name = "gestational";
                gestationalInputRadio2.type = "radio";
                gestationalInputRadio2.value = "no";
                // bind listen event
                gestationalInputRadio2.onblur = function() {
                    getValue(this);
                };
                gestationalDIV.appendChild(gestationalInputRadio2);
                gestationalDIV.appendChild(noText);
                gestationalDIV.appendChild(errorSpan);
                riskFactorField.appendChild(gestationalDIV);
                
                // append Polycystic Ovarian Syndrome (female only) div
                let POSDIV = document.createElement("div");
                POSDIV.class = "lgt-input-group";
                POSDIV.textContent = "Polycystic Ovarian Syndrome (female only): ";
                let POSInputRadio1 = document.createElement("input");
                POSInputRadio1.name = "POS";
                POSInputRadio1.type = "radio";
                POSInputRadio1.value = "yes";
                // bind listen event
                POSInputRadio1.onblur = function() {
                    getValue(this);
                };
                POSDIV.appendChild(POSInputRadio1);
                POSDIV.appendChild(yesText);
                
                let POSInputRadio2 = document.createElement("input");
                POSInputRadio2.name = "POS";
                POSInputRadio2.type = "radio";
                POSInputRadio2.value = "no";
                // bind listen event
                POSInputRadio2.onblur = function() {
                    getValue(this);
                };
                POSDIV.appendChild(POSInputRadio2);
                POSDIV.appendChild(noText);
                POSDIV.appendChild(errorSpan);
                riskFactorField.appendChild(POSDIV);
            }
            break;
        case 2:
            next.textContent = "Submit";
    }
    
    // show next question field
    fieldsets[count].style.display = "none";
    fieldsets[count + 1].style.display = "block";
    count++;
}

next.addEventListener('click', nextHandler);

// get value of each field
function getValue(obj) {
    switch(obj.name) {
        case "name":
            name = obj.value;
            console.log(name);
            break;
        case "age":
            age = obj.value;
            console.log(age);
            break;
        case "gender":
            gender = obj.value;
            console.log(gender);
            break;
        case "pregnant":
            pregnant = obj.value;
            console.log(pregnant);
            break;
        case "ogtt":
            ogtt = obj.value;
            console.log(ogtt);
            break;
        case "fpg":
            fpg = obj.value;
            console.log(fpg);
            break;
        case "cpg":
            cpg = obj.value;
            console.log(cpg);
            break;
    }
}


