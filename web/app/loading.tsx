export default function Loading() {
  return (
    <main className="min-h-screen grid place-items-center bg-white dark:bg-[#0B0F19]">
      <div className="flex flex-col items-center gap-4">
        <span className="w-16 h-16 rounded-full border-4 border-blue-600/20 border-t-blue-600 animate-spin" />
        <p className="text-lg font-semibold opacity-70">Faizan TV load ho raha hai...</p>
      </div>
    </main>
  );
}
