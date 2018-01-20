pragma solidity ^0.4.17;

contract Prescriptions {
    mapping(address => bool) admins;
    mapping(address => bool) doctors;
    mapping(address => bool) producers;

    struct MedicineBoxDefinition {
        uint medicineId;
        uint useBeforeDate;
        bool isConsumed;
    }
    mapping(uint => MedicineBoxDefinition) boxIdToDef;

    struct Prescription {
        address issuedDoctor;
        uint boxId;
    }
    mapping(address => mapping(uint => Prescription[])) prescriptions;

    function Prescriptions() public {
        admins[msg.sender] = true;
    }

    modifier forAdmins() {
        require(admins[msg.sender]);
        _;
    }

    modifier forDoctors() {
        require(doctors[msg.sender]);
        _;
    }

    modifier forProducers() {
        require(producers[msg.sender]);
        _;
    }

    function addAdmin(address admin) public forAdmins {
        admins[admin] = true;
    }

    function removeAdmin(address admin) public forAdmins {
        delete admins[admin];
    }

    function addDoctor(address doctor) public forAdmins {
        doctors[doctor] = true;
    }

    function removeDoctor(address doctor) public forAdmins {
        delete doctors[doctor];
    }

    function addProducer(address producer) public forAdmins {
        producers[producer] = true;
    }

    function removeProducer(address producer) public forAdmins {
        delete producers[producer];
    }

    event OnPrescriptionIssued(address patient, uint medicineId);
    event OnPrescriptionConsumed(address patient, uint medicineId);

    function issuePrescription(address patient, uint medicineId) public forDoctors {
        prescriptions[patient][medicineId].push(Prescription({
            issuedDoctor: msg.sender,
            boxId: 0
        }));
        OnPrescriptionIssued(patient, medicineId);
    }

    function issueMedicines(uint medicineId, uint useBeforeDate, uint[] boxIds) public forProducers {
        uint boxIdsLength = boxIds.length;
        for (uint boxIndex = 0; boxIndex < boxIdsLength; ++boxIndex) {
            boxIdToDef[boxIds[boxIndex]] = MedicineBoxDefinition({
                medicineId: medicineId,
                useBeforeDate: useBeforeDate,
                isConsumed: false
            });
       }
    }

    function collectMedicine(uint boxId) public {
        MedicineBoxDefinition storage boxDef = boxIdToDef[boxId];
        require(boxDef.useBeforeDate < now && !boxDef.isConsumed);
        uint medicineId = boxDef.medicineId;

        Prescription[] storage myThisMedicinePerscriptions = prescriptions[msg.sender][medicineId];
        bool prescriptionConsumed = false;
        for (uint nextPrescriptionIndex = myThisMedicinePerscriptions.length;
                nextPrescriptionIndex > 0; 
                --nextPrescriptionIndex) {
            if (myThisMedicinePerscriptions[nextPrescriptionIndex - 1].boxId == 0) {
                    myThisMedicinePerscriptions[nextPrescriptionIndex - 1].boxId = boxId;
                prescriptionConsumed = true;
                boxDef.isConsumed = true;
            }
        }
        require(prescriptionConsumed);
        OnPrescriptionConsumed(msg.sender, medicineId);
    }
}