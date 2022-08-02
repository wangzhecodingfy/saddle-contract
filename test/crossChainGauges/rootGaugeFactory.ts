import chai from "chai"
import { solidity } from "ethereum-waffle"
import { Signer } from "ethers"
import { deployments } from "hardhat"
import {
  AnyCallTranslator,
  RootGauge,
  RootGaugeFactory,
} from "../../build/typechain/"

chai.use(solidity)
const { expect } = chai

describe("RootGaugeFactory", () => {
  let signers: Array<Signer>
  let users: string[]
  let deployer: Signer
  let rootGaugeFactory: RootGaugeFactory
  let rootGauge: RootGauge
  let anycallTranslator: AnyCallTranslator

  const setupTest = deployments.createFixture(
    async ({ deployments, ethers }) => {
      await deployments.fixture(["veSDL"], { fallbackToGlobal: false }) // ensure you start from a fresh deployments

      console.log("test")
      signers = await ethers.getSigners()
      users = await Promise.all(
        signers.map(async (signer) => signer.getAddress()),
      )

      // Replace with mock address unless being tested on forked mainnet
      const anyCallAddress = "0x0000000000000000000000000000000000000000"

      // Deploy anycallTranslator
      const anyCallTranslatorFactory = await ethers.getContractFactory(
        "AnyCallTranslator",
      )
      anycallTranslator = (await anyCallTranslatorFactory.deploy(
        anyCallAddress,
      )) as AnyCallTranslator
      console.log("test")

      // Root Gauge factory
      const rootGaugeFactoryFactory = await ethers.getContractFactory(
        "RootGaugeFactory",
      )
      rootGaugeFactory = (await rootGaugeFactoryFactory.deploy(
        anycallTranslator.address,
        users[0],
      )) as RootGaugeFactory

      // Root Gauge Implementation
      const gaugeImplementationFactory = await ethers.getContractFactory(
        "RootGauge",
      )
      rootGauge = (await gaugeImplementationFactory.deploy(
        (
          await ethers.getContract("SDL")
        ).address,
        (
          await ethers.getContract("GaugeController")
        ).address,
        (
          await ethers.getContract("Minter")
        ).address,
      )) as RootGauge
    },
  )

  beforeEach(async () => {
    await setupTest()
  })

  describe("RootGaugeFactory", () => {
    it(`Successfully sets root gauge implementation`, async () => {
      // Initialize checkpoint by calling it first when empty
      await rootGaugeFactory.set_implementation(rootGauge.address)
      expect(await rootGaugeFactory.get_implementation()).to.eq(
        rootGauge.address,
      )
    })
  })
})
