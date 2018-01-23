var Prescriptions = artifacts.require("Prescriptions");


contract("Prescriptions", accounts => {
    it("Should allow to the doctor to save a prescription", () => {
        let contract;
        const doctor = accounts[1];
        const patient = accounts[2];
        const medicineId = Math.round(1000000 * Math.random());
        return Prescriptions.deployed()
            .then(instance => {
                contract = instance;
                return contract.addDoctor(doctor);
            })
            .then(() => 
                contract.issuePrescription(patient, medicineId, {from: doctor})
            );
    });

    it("Should allow to the producer to issue medicines", () => {
        let contract;
        const producer = accounts[1];
        const medicineId = Math.round(1000000 * Math.random());
        const boxes = [
            10000000 + Math.round(1000000 * Math.random()),
            10000000 + Math.round(1000000 * Math.random())
        ];
        return Prescriptions.deployed()
            .then(instance => {
                contract = instance;
                return contract.addProducer(producer);
            }).then(() =>
                contract.issueMedicines(medicineId, 1000000, boxes, {from: producer})
            );
    });

    it("Should allow to the patient to take his medicine", () => {
        let contract;
        const producer = accounts[1];
        const doctor = accounts[2];
        const patient = accounts[3];
        const medicineId = Math.round(1000000 * Math.random());
        const boxes = [
            10000000 + Math.round(1000000 * Math.random()),
            10000000 + Math.round(1000000 * Math.random())
        ];
        return Prescriptions.deployed()
            .then(instance => {
                contract = instance;
                return contract.addProducer(producer);
            }).then(() =>
                contract.addDoctor(doctor)
            ).then(() =>
                contract.issueMedicines(medicineId, 1000000, boxes, {from: producer})
            ).then(() =>
                contract.issuePrescription(patient, medicineId, {from: doctor})
            ).then(() =>
                contract.collectMedicine(boxes[1], {from: patient})
            );
    });

    // test for disallow scenarios
    // test via another admin
    // test another sequence of operations of issueMedicine and issuePrescription
    // no one can consume the same box twice
    // if you have two prescriptions you should be able to take two boxes
    // test another box
    // you can collect any box
    // you can not collect two boxes with one prescription
});