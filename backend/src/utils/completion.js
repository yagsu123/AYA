// src/utils/completion.js — profile completion % (formula from CLAUDE.md).
const FIELDS = [
  'full_name', 'email', 'dob', 'native_place', 'blood_group', 'photo_url',
  'res_address', 'office_address', 'mandal_category', 'mandal_position',
  'spouse_name', 'anniversary_date',
];

function calcCompletionPct(profile, children) {
  if (!profile) return 0;
  const filled = FIELDS.filter((f) => profile[f] && profile[f] !== '').length;
  const hasChild = children.length > 0 ? 1 : 0;
  return Math.round(((filled + hasChild) / (FIELDS.length + 1)) * 100);
}

module.exports = { calcCompletionPct };
