export default function SearchInput({ value, onChange, placeholder }) {
    return (
        <input
            type="text"
            className="w-full p-3 my-4 md:mb-8 border border-gray-300 rounded-md text-base text-center transition-all duration-300 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10"
            value={value}
            onChange={onChange}
            placeholder={placeholder}
        />
    )
}