import React from 'react';

export default function FormField({ label, name, type, value, onChange, error, placeholder, checked }) {
  const baseInputClass = "w-full px-4 py-2.5 bg-white border rounded-xl text-sm transition-all focus:outline-none focus:ring-2 focus:shadow-sm";
  const stateClass = error
    ? "border-red-300 focus:ring-red-500/20 focus:border-red-500"
    : "border-zinc-200 focus:ring-zinc-900/10 focus:border-zinc-900 hover:border-zinc-300";

  const inputProps = {
    type,
    name,
    id: name,
    value: type === 'checkbox' ? undefined : value,
    checked: type === 'checkbox' ? checked : undefined,
    onChange,
    placeholder,
    className: `${baseInputClass} ${stateClass}`,
  };

  return (
    <div className="space-y-1.5 mb-5 w-full">
      <label htmlFor={name} className="block text-sm font-semibold text-zinc-900 ml-1">{label}</label>
      {type === 'textarea' ? (
        <textarea {...inputProps} />
      ) : (
        <input {...inputProps} />
      )}
      {error && <div className="text-red-500 text-xs mt-1 ml-1 font-medium">{error}</div>}
    </div>
  );
}