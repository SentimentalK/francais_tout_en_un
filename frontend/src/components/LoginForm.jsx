import React from 'react';

export default function FormField({ label, name, type, value, onChange, error, placeholder, checked }) {
  const inputProps = {
    type,
    name,
    id: name,
    value: type === 'checkbox' ? undefined : value,
    checked: type === 'checkbox' ? checked : undefined,
    onChange,
    placeholder,
    className: error ? 'invalid' : '',
  };

  return (
    <div className="form-group">
      <label htmlFor={name}>{label}</label>
      {type === 'textarea' ? (
        <textarea {...inputProps} />
      ) : (
        <input {...inputProps} />
      )}
      {error && <div className="error-message show">{error}</div>}
    </div>
  );
}