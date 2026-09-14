#pragma once
#include <cstdint>
#include <functional>
#include <memory>
#include <string>
using u64 = uint64_t;
namespace DiscIO {
struct Partition {};
struct FileInfo { u64 GetTotalChildren() const { return 1; } };
struct FileSystem {
 bool IsValid() const { return true; }
 FileInfo GetRoot() const { return {}; }
};
struct Volume {
 Partition GetGamePartition() const { return {}; }
 const FileSystem* GetFileSystem(Partition) const { static FileSystem fs; return &fs; }
};
inline std::unique_ptr<Volume> CreateVolume(const char*) { return std::make_unique<Volume>(); }
inline bool ExportSystemData(const Volume&, Partition, const std::string&) { return true; }
inline void ExportDirectory(const Volume&, Partition, FileInfo, bool, const char*, const std::string&,
                            const std::function<bool(const std::string&)>& callback) {
 callback("fixture.dat");
}
}
