/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

// When user refresh the page, 
// browser will auto complete 
// field with last value.
// Thus, attributes should
// be initialized at decleration stage.
let age;
let gender;
if (document.getElementsByName("gender")[0].checked) {
    gender = document.getElementsByName("gender")[0].value;
}
if (document.getElementsByName("gender")[1].checked) {
    gender = document.getElementsByName("gender")[1].value;
    document.querySelector('#pregnant-group').style.display = 'block';
}
let pregnant;
if (document.getElementsByName("pregnant")[0].checked) {
    pregnant = document.getElementsByName("pregnant")[0].value;
}
if (document.getElementsByName("pregnant")[1].checked) {
    pregnant = document.getElementsByName("pregnant")[1].value;
}
let OGTT = document.getElementsByName("OGTT")[0].value;
let FPG;
let CPG;
let obesity = document.getElementsByName("obesity")[0].value;
let bloodPressure;
if (document.getElementsByName("blood-pressure")[0].checked) {
    bloodPressure = document.getElementsByName("blood-pressure")[0].value;
}
if (document.getElementsByName("blood-pressure")[1].checked) {
    bloodPressure = document.getElementsByName("blood-pressure")[1].value;
}
let familyHistory;
if (document.getElementsByName("family-history")[0].checked) {
    familyHistory = document.getElementsByName("family-history")[0].value;
}
if (document.getElementsByName("family-history")[1].checked) {
    familyHistory = document.getElementsByName("family-history")[1].value;
}
let TG;
if (document.getElementsByName("TG")[0].checked) {
    TG = document.getElementsByName("TG")[0].value;
}
if (document.getElementsByName("TG")[1].checked) {
    TG = document.getElementsByName("TG")[1].value;
}
if (document.getElementsByName("TG")[2].checked) {
    TG = document.getElementsByName("TG")[2].value;
}
let lowActivity;
if (document.getElementsByName("low-activity")[0].checked) {
    lowActivity = document.getElementsByName("low-activity")[0].value;
}
if (document.getElementsByName("low-activity")[1].checked) {
    lowActivity = document.getElementsByName("low-activity")[1].value;
}
let IGT;
if (document.getElementsByName("IGT")[0].checked) {
    IGT = document.getElementsByName("IGT")[0].value;
}
if (document.getElementsByName("IGT")[1].checked) {
    IGT = document.getElementsByName("IGT")[1].value;
}
let gestational;
let POS;
let headache;
if (document.getElementsByName("headache")[0].checked) {
    headache = document.getElementsByName("headache")[0].value;
}
if (document.getElementsByName("headache")[1].checked) {
    headache = document.getElementsByName("headache")[1].value;
}
let BV;
if (document.getElementsByName("BV")[0].checked) {
    BV = document.getElementsByName("BV")[0].value;
}
if (document.getElementsByName("BV")[1].checked) {
    BV = document.getElementsByName("BV")[1].value;
}
let EU;
if (document.getElementsByName("EU")[0].checked) {
    EU = document.getElementsByName("EU")[0].value;
}
if (document.getElementsByName("EU")[1].checked) {
    EU = document.getElementsByName("EU")[1].value;
}
let polydipsia;
if (document.getElementsByName("polydipsia")[0].checked) {
    polydipsia = document.getElementsByName("polydipsia")[0].value;
}
if (document.getElementsByName("polydipsia")[1].checked) {
    polydipsia = document.getElementsByName("polydipsia")[1].value;
}
let LC;
if (document.getElementsByName("LC")[0].checked) {
    LC = document.getElementsByName("LC")[0].value;
}
if (document.getElementsByName("LC")[1].checked) {
    LC = document.getElementsByName("LC")[1].value;
}
let NV;
if (document.getElementsByName("NV")[0].checked) {
    NV = document.getElementsByName("NV")[0].value;
}
if (document.getElementsByName("NV")[1].checked) {
    NV = document.getElementsByName("NV")[1].value;
}
let polyphagia;
if (document.getElementsByName("polyphagia")[0].checked) {
    polyphagia = document.getElementsByName("polyphagia")[0].value;
}
if (document.getElementsByName("polyphagia")[1].checked) {
    polyphagia = document.getElementsByName("polyphagia")[1].value;
}
let tiredness;
if (document.getElementsByName("tiredness")[0].checked) {
    tiredness = document.getElementsByName("tiredness")[0].value;
}
if (document.getElementsByName("tiredness")[1].checked) {
    tiredness = document.getElementsByName("tiredness")[1].value;
}
let LW;
if (document.getElementsByName("LW")[0].checked) {
    LW = document.getElementsByName("LW")[0].value;
}
if (document.getElementsByName("LW")[1].checked) {
    LW = document.getElementsByName("LW")[1].value;
}
let FST;
if (document.getElementsByName("FST")[0].checked) {
    FST = document.getElementsByName("FST")[0].value;
}
if (document.getElementsByName("FST")[1].checked) {
    FST = document.getElementsByName("FST")[1].value;
}
let FI;
if (document.getElementsByName("FI")[0].checked) {
    FI = document.getElementsByName("FI")[0].value;
}
if (document.getElementsByName("FI")[1].checked) {
    FI = document.getElementsByName("FI")[1].value;
}
let sensation;
if (document.getElementsByName("sensation")[0].checked) {
    sensation = document.getElementsByName("sensation")[0].value;
}
if (document.getElementsByName("sensation")[1].checked) {
    sensation = document.getElementsByName("sensation")[1].value;
}
let coldSweat;
if (document.getElementsByName("cold-sweat")[0].checked) {
    coldSweat = document.getElementsByName("cold-sweat")[0].value;
}
if (document.getElementsByName("cold-sweat")[1].checked) {
    coldWweat = document.getElementsByName("cold-sweat")[1].value;
}

let next = document.querySelector("#next"); // next button
next.addEventListener('click', nextHandler);
let navItems = document.getElementsByClassName("lgt-nav-item");
//let container = document.querySelector("section"); // top container
let fieldsets = document.querySelectorAll("fieldset"); // select all question fields
let pages = document.querySelectorAll(".page"); // select all question fields
let count = 0;

// error check
function check() {
    let checked = true;
    let length = arguments.length;
    for(let i = 0; i < length; i++) {
        checked = checked && arguments[i];
    }
    if (!checked) {
        alert("Please fill all fields correctly before you go the next part!");
    }
    return checked;
}

// check number
// type: 1. Integer, 2. Float
function checkNumber (obj, type) {
    let r, msg;
    
    // test different regular expression for integer and float
    switch (type) {
        case 1:
            r = /^[0-9]*[1-9][0-9]*$/;
            msg = "Please input valid integer!";
            break;
        case 2:
            r = /^\d+(\.\d+)?$/;
            msg = "Please input valid float!";
            break;
    }
    
    if (r.test(obj.value)) {
        obj.nextElementSibling.textContent = "";
        obj.style.border = "2px solid #4caf50";
    } else {
        obj.nextElementSibling.textContent = msg;
        obj.style.border = "2px solid #d32F2f";
    }
    return r.test(obj.value);
}

// loading next "page"
function nextHandler() {
    switch(count) {
        case 0:
            if (gender === "male") {
                pregnant = "no";
            }
            if (!check(gender, pregnant, age)) {
                return;
            }
            
            let testField = fieldsets[1];

            // pregant women don't need do following test
            if (pregnant === 'no') {
                // append FPG div
                let FPGDIV = document.createElement("div");
                FPGDIV.classList.add("lgt-input-group");
                FPGDIV.textContent = "How much is your blood glucose level (mmol/L) shown in Fasting Plasma Glucose test (FPG) ? ";
                let FPGInput = document.createElement("input");
                FPGInput.name = "FPG";
                FPGInput.type = "text";
                FPGInput.classList.add("lgt-text-input");
                // bind listen event
                FPGInput.onblur = function() {
                    getValue(this);
                };
                FPGDIV.appendChild(FPGInput);
                let errorSpan = document.createElement("span");
                errorSpan.classList.add('lgt-error');
                FPGDIV.appendChild(errorSpan);
                testField.appendChild(FPGDIV);

                // append CPG div
                let CPGDIV = document.createElement("div");
                CPGDIV.classList.add("lgt-input-group");
                CPGDIV.textContent = "How much is your blood glucose level (mmol/L) shown in Casual Plasma Glucose test (CPG) ? ";
                let CPGInput = document.createElement("input");
                CPGInput.name = "CPG";
                CPGInput.type = "text";
                CPGInput.classList.add("lgt-text-input");
                // bind listen event
                CPGInput.onblur = function() {
                    getValue(this);
                };
                CPGDIV.appendChild(CPGInput);
                errorSpan = document.createElement("span");
                errorSpan.classList.add('lgt-error');
                CPGDIV.appendChild(errorSpan);
                testField.appendChild(CPGDIV);
            }
            break;
        case 1:
            if (OGTT === "error" || FPG === "error" || CPG === "error") {
                check(false);
                return;
            }
//            if (pregnant === "no") {
//                if (!check(OGTT, FPG, CPG)) {
//                    return;
//                }
//            }
            
            let riskFactorField = fieldsets[2];

            // the follwing questions only for women
            if (gender === 'female') {
                // append History of gestational diabetes or Having Baby with over 4 Kg weight (female only) div
                let gestationalDIV = document.createElement("div");
                gestationalDIV.classList.add("lgt-input-group");
                gestationalDIV.textContent = "Do you have history of gestational diabetes or having baby with over 4kg? ";
                let gestationalInputRadio1 = document.createElement("input");
                gestationalInputRadio1.name = "gestational";
                gestationalInputRadio1.type = "radio";
                gestationalInputRadio1.value = "yes";
                // bind listen event
                gestationalInputRadio1.onblur = function() {
                    getValue(this);
                };
                gestationalDIV.appendChild(gestationalInputRadio1);
                gestationalDIV.appendChild(document.createTextNode(" Yes"));
                
                let gestationalInputRadio2 = document.createElement("input");
                gestationalInputRadio2.name = "gestational";
                gestationalInputRadio2.type = "radio";
                gestationalInputRadio2.value = "no";
                // bind listen event
                gestationalInputRadio2.onblur = function() {
                    getValue(this);
                };
                gestationalDIV.appendChild(gestationalInputRadio2);
                gestationalDIV.appendChild(document.createTextNode(" No"));
                let errorSpan = document.createElement("span");
                errorSpan.classList.add('lgt-error');
                gestationalDIV.appendChild(errorSpan);
                riskFactorField.appendChild(gestationalDIV);
                
                // append Polycystic Ovarian Syndrome (female only) div
                let POSDIV = document.createElement("div");
                POSDIV.classList.add("lgt-input-group");
                POSDIV.textContent = "Do you have Polycystic Ovarian Syndrome? ";
                let POSInputRadio1 = document.createElement("input");
                POSInputRadio1.name = "POS";
                POSInputRadio1.type = "radio";
                POSInputRadio1.value = "yes";
                // bind listen event
                POSInputRadio1.onblur = function() {
                    getValue(this);
                };
                POSDIV.appendChild(POSInputRadio1);
                POSDIV.appendChild(document.createTextNode(" Yes"));
                
                let POSInputRadio2 = document.createElement("input");
                POSInputRadio2.name = "POS";
                POSInputRadio2.type = "radio";
                POSInputRadio2.value = "no";
                // bind listen event
                POSInputRadio2.onblur = function() {
                    getValue(this);
                };
                POSDIV.appendChild(POSInputRadio2);
                POSDIV.appendChild(document.createTextNode(" No"));
                errorSpan = document.createElement("span");
                errorSpan.classList.add('lgt-error');
                POSDIV.appendChild(errorSpan);
                riskFactorField.appendChild(POSDIV);
            }
            break;
        case 2:
            if (obesity === "error") {
                check(false);
                return;
            }
//            if (!check(obesity, bloodPressure, familyHistory, TG, lowActivity, IGT)) {
//                return;
//            }
//            if (gender === "female") {
//                if (!check(gestational, POS)) {
//                    return;
//                }
//            }
            next.textContent = "View >";
            break;
        case 3:
//            if (!check(headache, BV, EU, TG, polydipsia, LC, NV, polyphagia, tiredness, LW, FST, FI, sensation, coldSweat)) {
//                return;
//            }
            submit();
            navItems[count].classList.remove("lgt-primary-text");
//            navItems[count + 1].classList.add("lgt-primary-text");
            return;
    }
    
    // show next question field
    navItems[count].classList.remove("lgt-primary-text");
    navItems[count + 1].classList.add("lgt-primary-text");
//    fieldsets[count].style.display = "none";
//    fieldsets[count + 1].style.display = "block";
    pages[count].className = ("lgt-card page stage-left");
    pages[count + 1].className = ("lgt-card page stage-center");
    count++;
}

function submit() {
    let submitData = "age=" + age + "&" + "gender=" + gender + "&"
            + "pregnant=" + pregnant + "&" + "OGTT=" + OGTT + "&" + "FPG=" + FPG + "&"
            + "CPG=" + CPG + "&" + "obesity=" + obesity + "&" + "bloodPressure=" + bloodPressure + "&"
            + "familyHistory=" + familyHistory + "&" + "TG=" + TG + "&" + "lowActivity=" + lowActivity + "&"
            + "IGT=" + IGT + "&" + "gestational=" + gestational + "&"
            + "POS=" + POS + "&" + "headache=" + headache + "&" + "BV=" + BV + "&"
            + "EU=" + EU + "&" + "polydipsia=" + polydipsia + "&" + "LC=" + LC + "&"
            + "NV=" + NV + "&" + "polyphagia=" + polyphagia + "&" + "tiredness=" + tiredness + "&"
            + "LW=" + LW + "&" + "FST=" + FST + "&" + "FI=" + FI + "&"
            + "sensation=" + sensation + "&" + "coldSweat=" + coldSweat;
    
    let xhttp;
    if (window.XMLHttpRequest) {
        xhttp = new XMLHttpRequest();
    } else {
        // code for IE6, IE5
        xhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    
    xhttp.onreadystatechange = function() {
        if (this.readyState === 4 && this.status === 200) {
            let result = JSON.parse(this.responseText);
            if (pregnant !== "yes") {
                result["gestational-diabetes"] = 0;
            }
            
//            fieldsets[3].style.display = "none";
            pages[3].className = ("lgt-card page stage-left");
            pages[4].className = ("lgt-card page stage-center");
            
            next.style.display = "none";
            let resultDiv = document.querySelector(".result");
            
            if (result["diabetes-type-I"] < 0) {
                result["diabetes-type-I"] = 0;
            }
            if (result["diabetes-type-II"] < 0) {
                result["diabetes-type-II"] = 0;
            }
            if (result["gestational-diabetes"] < 0) {
                result["gestational-diabetes"] = 0;
            }
            if (result["diabetes-type-I"] > 0) {
                resultDiv.innerHTML = "<em class='bullet bullet-pink'></em>You have <b>" + parseInt(result["diabetes-type-I"]*100) + "%</b> chance of having diabetes-type-I<br/>";
            }
            if (result["diabetes-type-II"] > 0) {
                resultDiv.innerHTML = "<em class='bullet bullet-pink'></em>You have <b>" + parseInt(result["diabetes-type-II"]*100) + "%</b> chance of having diabetes-type-II<br/>";
            }
            if (result["gestational-diabetes"] > 0) {
                resultDiv.innerHTML = "<em class='bullet bullet-pink'></em>You have <b>" + parseInt(result["gestational-diabetes"]*100) + "%</b> chance of having gestational-diabetes<br/>";
            }
//            resultDiv.innerHTML += "diabetes-type-I: " + result["diabetes-type-I"]*100 + "%<br/>";
//            resultDiv.innerHTML += "diabetes-type-II: " + result["diabetes-type-II"]*100 + "%<br/>";
//            resultDiv.innerHTML += "gestational-diabetes: " + result["gestational-diabetes"]*100 + "%<br/>";
            
            let recommendationDiv = document.querySelector(".recommendation");
            let recommendation = "";
            if (result["healthy"] == 1) {
                recommendation = "Congratulation! You are healthy!"
            }
            if (result["more-consideration"] == 1) {
                recommendation = "You should seek further medical consultation!"
            }
            if (result["at-risk"] == 1) {
                recommendation = "Warning! You are at risk of having diabetes."
            }
            let key;
            let allZero = 0;
            for(key in result) {
//                resultDiv.innerHTML += key + ": " + result[key]*100 + "%<br/>";
                allZero += result[key];
            }
            if (allZero === 0) {
                recommendation = "Not enough information."
            }
            recommendationDiv.innerHTML = "<em class='bullet bullet-blue'></em>" + recommendation;
        }
    };
    xhttp.open("POST", "Recommend", true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.send(submitData);
}

// get value of each field
function getValue(obj) {
    switch(obj.name) {
        case "age":
            if (checkNumber(obj, 1)) {
                age = obj.value;
                console.log(age);
            } else {
                age = "error";
            }
            break;
        case "gender":
            gender = obj.value;
            console.log(gender);
            break;
        case "pregnant":
            pregnant = obj.value;
            console.log(pregnant);
            break;
        case "OGTT":
            if (obj.value === "") {
                break;
            }
            if (checkNumber(obj, 2)) {
                OGTT = obj.value;
                console.log(OGTT);
            } else {
                OGTT = "error";
            }
            break;
        case "FPG":
            if (obj.value === "") {
                break;
            }
            if (checkNumber(obj, 2)) {
                FPG = obj.value;
                console.log(FPG);
            } else {
                FPG = "error";
            }
            break;
        case "CPG":
            if (obj.value === "") {
                break;
            }
            if (checkNumber(obj, 2)) {
                CPG = obj.value;
                console.log(CPG);
            } else {
                CPG = "error";
            }
            break;
        case "obesity":
            if (obj.value === "") {
                break;
            }
            if (checkNumber(obj, 2)) {
                obesity = obj.value;
                console.log(obesity);
            } else {
                obesity = "error";
            }
            break;
        case "blood-pressure":
            bloodPressure = obj.value;
            console.log(bloodPressure);
            break;
        case "family-history":
            familyHistory = obj.value;
            console.log(familyHistory);
            break;
        case "TG":
            TG = obj.value;
            console.log(TG);
            break;
        case "low-activity":
            lowActivity = obj.value;
            console.log(lowActivity);
            break;
        case "IGT":
            IGT = obj.value;
            console.log(IGT);
            break;
        case "gestational":
            gestational = obj.value;
            console.log(gestational);
            break;
        case "POS":
            POS = obj.value;
            console.log(POS);
            break;
        case "headache":
            headache = obj.value;
            console.log(headache);
            break;
        case "BV":
            BV = obj.value;
            console.log(BV);
            break;
        case "EU":
            EU = obj.value;
            console.log(EU);
            break;
        case "polydipsia":
            polydipsia = obj.value;
            console.log(polydipsia);
            break;
        case "LC":
            LC = obj.value;
            console.log(LC);
            break;
        case "NV":
            NV = obj.value;
            console.log(NV);
            break;
        case "polyphagia":
            polyphagia = obj.value;
            console.log(polyphagia);
            break;
        case "tiredness":
            tiredness = obj.value;
            console.log(tiredness);
            break;
        case "LW":
            LW = obj.value;
            console.log(LW);
            break;
        case "FST":
            FST = obj.value;
            console.log(FST);
            break;
        case "FI":
            FI = obj.value;
            console.log(FI);
            break;
        case "sensation":
            sensation = obj.value;
            console.log(sensation);
            break;
        case "cold-sweat":
            coldSweat = obj.value;
            console.log(coldSweat);
            break;
    }
}