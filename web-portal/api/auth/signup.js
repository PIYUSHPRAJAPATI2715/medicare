import registerPatientHandler from './register-patient.js';

export default function handler(req, res) {
  return registerPatientHandler(req, res);
}
