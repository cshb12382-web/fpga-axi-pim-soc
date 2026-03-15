# fpga-axi-pim-soc
FPGA-Based Simple MIPS Processor, 공정 미세화 한계 극복을 위한 AXI 기반 SoC 통합 및 PIM 개념의 Near-Memory 하드웨어 가속기 설계

# 🚀 FPGA/SoC 하드웨어 설계 포트폴리오
> **Multi-Cycle MIPS Processor & AXI-based PIM Accelerator SoC**
> 
> **📄 [상세 포트폴리오 다운로드 (PDF)](./HW_포트폴리오.pdf)** // HW_PORTFOLIO

---_


## 💡 프로젝트 1. FPGA-Based Simple MIPS Processor
직접 RTL로 설계한 16-bit Multi-Cycle CPU 코어입니다.

### 🛠️ 핵심 구현 내용
* **Core Design:** 기본적인 MIPS 명령어 셋 처리를 위한 Data Path 및 Control Unit(FSM) 설계
* **ALU Optimization:** Carry Look-ahead Adder를 직접 설계/적용하여 덧셈 연산 속도 개선
* **I/O Interface:** UART 통신 프로토콜을 구현하여 PC-FPGA 간 외부 데이터 입력 환경 구축
* **Hardware Debugging:** FPGA 보드의 Push Button을 활용한 사이클 단위 Step-by-Step 동작 검증

---
**Tech Stack:** `Verilog HDL`, `Xilinx Vivado`, `FPGA Prototyping (Nexys A7, AX7035B(Artix))`, `UART`, 'ILA'

## 💡 프로젝트 2. AXI 기반 SoC 통합 및 Near-Memory (PIM) 가속기 설계
기존 폰노이만 구조가 직면한 메모리 병목 현상과 선단 공정에서의 배선 지연 및 전력 소모 문제를 아키텍처 레벨에서 극복하기 위해 기획된 메인 프로젝트입니다.

### 🛠️ 핵심 아키텍처 및 구현
* **System Bus:** 32-bit AMBA AXI4-Lite Protocol (Master/Slave 통합)
* **Memory Subsystem:** Xilinx BRAM IP 연동 (Byte-to-Word Address Translation)
* **Accelerator:** Near-Memory MAC PIM 가속기 설계 (AI 연산 최적화)
* **Verification:** Xilinx Vivado ILA를 활용한 온칩 하드웨어 실측 디버깅

### 📊 물리적 특성 기반 PPA 최적화 성과
1. **Performance (데이터 이동 최소화):** ILA 실측 결과, 데이터량 증가에 따라 버스 초기 오버헤드가 상쇄되며 하드웨어 성능(추가 데이터당 약 2 Cycle 비용)에 안정적으로 수렴함을 증명.
2. **Power & Energy (동적 전력 억제):** Vivado Power Report 분석 결과, 칩 전체를 가로지르는 배선 전력이 11%로 도출. BEOL 라우팅 혼잡도와 발열을 분산시키는 공정 친화적 검증.
3. **Area & Reliability (타이밍 마진 확보):** WNS 4.031ns를 확보하여 PVT 변동성 환경에서도 견고한 62.6MHz 동작 신뢰성 입증. 대형 캐시 메모리를 배제하여 ASIC 전환 시 Die Size 축소 기여.

---
